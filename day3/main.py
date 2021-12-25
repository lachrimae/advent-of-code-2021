def oxygen_generator_predicate(column_index, num_zeroes, num_ones, num_to_check):
    if num_zeroes > num_ones:
        return num_to_check[column_index] == '0'
    elif num_zeroes < num_ones:
        return num_to_check[column_index] == '1'
    else:
        return num_to_check[column_index] == '1'

def co2_scrubber_predicate(column_index, num_zeroes, num_ones, num_to_check):
    return not oxygen_generator_predicate(column_index, num_zeroes, num_ones, num_to_check)

with open('input.txt') as f:
    data = f.read().split('\n')[:-1]

def find_rating(data, rating_pred):
    num_lines = len(data)
    for column in range(len(data[0])):
        num_zeroes = 0
        num_ones = 0
        for line in data:
            if line[column] == '0':
                num_zeroes += 1
            else:
                num_ones += 1
        data = list(filter(lambda line: rating_pred(column, num_zeroes, num_ones, line), data))
        num_lines = len(data)
        if num_lines <= 1:
            break
    return int(data[0], 2)

oxygen_list = data
co2_list = data.copy()

oxygen_rating = find_rating(oxygen_list, oxygen_generator_predicate)
co2_rating = find_rating(co2_list, co2_scrubber_predicate)

print(oxygen_rating * co2_rating)
