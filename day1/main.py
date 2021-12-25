with open('input.txt') as f:
    lines = f.read().split('\n')

count1 = 0
count2 = 0
for i in range(1, len(lines)):
    try:
        if int(lines[i]) > int(lines[i-1]):
            count1 += 1
        if i >= 3:
            if int(lines[i]) > int(lines[i-3]):
                count2 += 1
    except ValueError:
        continue

print(count1)
print(count2)
