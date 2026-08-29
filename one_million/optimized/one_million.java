import java.io.BufferedOutputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

class OneMillion {
	public static void main(String[] args) throws Exception {
		OutputStream out = new BufferedOutputStream(System.out, 65536);
		byte[] prefix = "Hello, this is iteration number: ".getBytes(StandardCharsets.US_ASCII);
		byte[] numBuf = new byte[16];

		for (int i = 0; i < 1000000; i++) {
			out.write(prefix);
			int temp = i;
			int digits = 0;
			if (temp == 0) {
				numBuf[digits++] = '0';
			} else {
				while (temp > 0) {
					numBuf[digits++] = (byte) ('0' + (temp % 10));
					temp /= 10;
				}
			}
			for (int j = digits - 1; j >= 0; j--) {
				out.write(numBuf[j]);
			}
			out.write('\n');
		}
		out.flush();
	}
}
