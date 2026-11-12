# KDBX interop fixtures

Files of the same content written by two libraries, which
`test/interop/interop_fixtures_test.dart` opens on the VM and in the browser
(`dart test -p chrome`):

| File | Written by | KDF | Cipher |
| --- | --- | --- | --- |
| `tom_kdbx_argon2d_aes.kdbx` | `tom_kdbx` 2.4.2+tom.4 (its default format) | Argon2d, 1 MiB | AES-256 |
| `tom_kdbx_argon2d_chacha20.kdbx` | `tom_kdbx` 2.4.2+tom.4 | Argon2d, 1 MiB | ChaCha20 |
| `tom_kpasslib_argon2d_aes.kdbx` | `tom_kpasslib` on the VM | Argon2d, 256 KiB | AES-256 |
| `tom_kpasslib_argon2id_chacha20.kdbx` | `tom_kpasslib` on the VM | Argon2id, 512 KiB, 3 iterations, 2 lanes | ChaCha20 |
| `tom_kpasslib_aeskdf_aes.kdbx` | `tom_kpasslib` on the VM | AES-KDF, 1000 rounds | AES-256 |

Password `interop`. One entry: title `interop title`, protected password
`interop secret`, a field `Note` with `unicode ✓ äöü`, an attachment `a.txt`
holding `attached bytes`; the meta custom data `k` = `v`.

`tom_kdbx` is the workspace's fork of AuthPass's `kdbx.dart` (GPL-3), the
library `tom_kpasslib` replaces in the Tom Framework. The generator therefore
lives outside this repository, in the Tom workspace's quest folder
(`_ai/quests/tom_core/ideas/tom_secrets_manager/kdbx_interop_fixtures/`), and
only its output files are here.
