#include <unistd.h>
#include <string.h>

#define BUF_SIZE (64 * 1024)

int main(void) {
	char buffer[BUF_SIZE];
	size_t pos = 0;
	const char prefix[] = "Hello, this is iteration number: ";
	const size_t prefix_len = sizeof(prefix) - 1;

	for (int n = 0; n < 1000000; n++) {
		if (pos + prefix_len + 12 > BUF_SIZE) {
			if (write(1, buffer, pos) < 0) return 1;
			pos = 0;
		}
		memcpy(buffer + pos, prefix, prefix_len);
		pos += prefix_len;

		char num_buf[10];
		int temp = n;
		int digits = 0;
		if (temp == 0) {
			num_buf[digits++] = '0';
		} else {
			while (temp > 0) {
				num_buf[digits++] = (char)('0' + (temp % 10));
				temp /= 10;
			}
		}
		for (int j = digits - 1; j >= 0; j--) {
			buffer[pos++] = num_buf[j];
		}
		buffer[pos++] = '\n';
	}
	if (pos > 0) {
		if (write(1, buffer, pos) < 0) return 1;
	}
	return 0;
}
