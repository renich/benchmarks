use std::io::{stdout, BufWriter, Write};

fn main() -> std::io::Result<()> {
    let stdout = stdout();
    let mut handle = BufWriter::with_capacity(64 * 1024, stdout.lock());
    let prefix = b"Hello, this is iteration number: ";
    let mut num_buf = [0u8; 10];

    for n in 0..1_000_000 {
        handle.write_all(prefix)?;
        let mut temp = n;
        let mut idx = num_buf.len();
        if temp == 0 {
            idx -= 1;
            num_buf[idx] = b'0';
        } else {
            while temp > 0 {
                idx -= 1;
                num_buf[idx] = b'0' + (temp % 10) as u8;
                temp /= 10;
            }
        }
        handle.write_all(&num_buf[idx..])?;
        handle.write_all(b"\n")?;
    }
    handle.flush()?;
    Ok(())
}
