# TEE, confidential computing, attestation

The engineer works on SGX/TDX, attestation, and IMA/RTMR. These invert or extend
the usual threat model — what counts as attacker-controlled changes.

## Confidential-computing guest (TDX / SEV-SNP) — inverted threat model

In a CoCo guest the **host/hypervisor/VMM is untrusted** (the adversary). Trusted:
the guest kernel, guest private memory, and the CPU. Untrusted attack surface =
everything the host controls:

- port I/O & MMIO, DMA, PCI config space
- VMM hypercalls, host-injected interrupts, `#VC`/`#VE` handling
- **shared/bounce memory pages** and virtio rings
- the initial configuration (firmware, bootloader, kernel image, cmdline)

Audit consequence: in CoCo-guest code, host-provided data is attacker-controlled
exactly like userspace data. Every read from a shared/bounce buffer, MMIO
register, or virtio ring must be validated and bounds-checked — and is subject to
**double-fetch**: the host can mutate shared memory between reads, so fetch once
into private memory and validate the private copy ([user-boundary.md](user-boundary.md)).

```c
// Bad: trusts a length from a host-shared virtio ring, re-reads it.
len = shared->len;
if (len > MAX) return -EINVAL;
memcpy(priv, shared->data, shared->len);   // host changed shared->len after the check

// Good: snapshot each scalar with READ_ONCE (a whole-struct copy is NOT a single
// fetch — the compiler may tear it into multiple loads the host can race).
u32 len = READ_ONCE(shared_hdr->len);
if (len > MAX) return -EINVAL;
memcpy(priv, shared->data, len);  // use the validated snapshot, never re-read shared
```

Reference: the kernel's SNP/TDX guest threat model documents four host threat
categories (malicious config, data-in-transit tampering, malformed input,
malicious-but-valid input).

## SGX enclave boundary (ECALL / OCALL)

Everything outside the enclave + CPU is untrusted (OS, host app). The EDL
`[in]/[out]` annotations generate trusted-bridge code that marshals and
bounds-checks ECALL pointers (`sgx_is_outside_enclave` / `sgx_is_within_enclave`).

- Any direct dereference of **host memory** from inside the enclave is a
  TOCTOU/double-fetch risk — copy into enclave memory once and operate on the copy.
- Mirror the infoleak rule: zero enclave-resident structs before copying out, or
  padding leaks enclave memory.
- **OCALL / AEX re-entrancy (SmashEx, CVE-2021-0186)** — the most important
  non-obvious enclave-runtime bug. A malicious OS injects an asynchronous
  exception (AEX) right after enclave entry or OCALL return, *before* the
  in-enclave exception state is consistent, re-entering the enclave and hijacking
  control flow → enclave-memory disclosure / in-enclave ROP. Audit that the
  runtime serializes exception handling and blocks re-entrancy across the OCALL
  boundary and on AEX (fixed in SGX SDK 2.13/2.14, Open Enclave 0.17.1).

## Attestation / measurements (IMA / RTMR) — CWE-345

An attestation report is only meaningful if the verifier checks the **full** set
of measured components against expected reference values, the **nonce/freshness**,
and the **certificate chain** to a trusted root.

Flag as authenticity/verification bugs:
- a missing nonce/freshness check → replay.
- an unvalidated or partially-validated measurement entry.
- accepting a report without verifying the signature chain to a trusted root.
- comparing only some PCRs/RTMRs, or not failing closed on mismatch.

```c
// Bad: verifies the signature but never checks freshness or the measurement set.
if (verify_sig(report, key) != 0) return -EINVAL;
return 0;   // accepted — replayable, and measurements unchecked

// Good: signature + nonce + full measurement comparison + chain to trusted root.
if (verify_sig(report, key)) return -EINVAL;
if (report->nonce != expected_nonce) return -EINVAL;     // freshness
if (memcmp(report->measurements, golden, sizeof golden)) return -EINVAL;
if (verify_chain(report->cert, trusted_root)) return -EINVAL;
```
