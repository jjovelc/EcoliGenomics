import random
import sys


def extract_random_lines(filename, num_lines):
    with open(filename, 'r') as f:
        lines = f.readlines()

    header = lines[0]
    data_lines = lines[1:]

    sampled_data = random.sample(data_lines, num_lines)
    return [header] + sampled_data

def main():
    filename = sys.argv[1]
    for n in [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]:
        extracted_lines = extract_random_lines(filename, n)
        with open(f"{n}_mash-group.txt", 'w') as f:
            f.writelines(extracted_lines)

if __name__ == "__main__":
    main()
