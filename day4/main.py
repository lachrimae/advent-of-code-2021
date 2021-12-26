with open('input.txt') as f:
    raw = f.read().split('\n')
    announcement_seq = raw[0].split(',')
    main_segment = raw[2:]
    boards = list()
    board = list()
    for line in main_segment:
        if line == '':
            boards.append(board)
            board = list()
        else:
            cleaned_line = ''
            was_space = False
            for char_index in range(len(line)):
                entry = ''
                if (char_index == 0 or was_space) and line[char_index] == ' ':
                    continue
                else:
                    cleaned_line += line[char_index]
                    was_space = line[char_index] == ' '
            entries = cleaned_line.split(' ')
            board.append(entries)

def find_result(boards, announcement_seq):
    announcements = set()
    num_columns = len(boards[0])
    for announcement in announcement_seq:
        announcements.add(announcement)
        for board_index in range(len(boards)):
            # horizontal rows
            for row in boards[board_index]:
                row_compatible = True
                for num in row:
                    if num not in announcements:
                        row_compatible = False
                        break
                if row_compatible:
                    return (boards[board_index], announcement, announcements)
            for column_index in range(num_columns):
                column_compatible = True
                for row in boards[board_index]:
                    if row[column_index] not in announcements:
                        column_compatible = False
                        break
                if column_compatible:
                    return (boards[board_index], announcement, announcements)

def score_board(board, winning_announcement, announcements_thus_far):
    unmarked_numbers = list()
    for row in board:
        for num in row:
            if num not in announcements_thus_far:
                unmarked_numbers.append(num)
    return int(winning_announcement) * sum(map(int, unmarked_numbers))

winning_board, last_number_called, announcements = find_result(boards, announcement_seq)
print(score_board(winning_board, last_number_called, announcements))
