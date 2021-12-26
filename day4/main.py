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
    winning_board = None
    winning_announcement = None
    announcements_thus_far = None
    losing_board = None
    total_number_of_announcements = len(announcement_seq)
    found_winner = False
    announcements_so_far = set()
    num_columns = len(boards[0])
    for announcement_index in range(total_number_of_announcements):
        announcements_so_far.add(announcement_seq[announcement_index])
        board_index = 0
        num_boards_left = len(boards)
        print(num_boards_left)
        if num_boards_left == 1:
            losing_board = boards[0]
            break
        while board_index < num_boards_left:
            deleted_a_board = False
            # horizontal rows
            won_by_row = False
            for row in boards[board_index]:
                row_compatible = True
                for num in row:
                    if num not in announcements_so_far:
                        row_compatible = False
                        break
                if row_compatible:
                    if not found_winner:
                        winning_board = boards[board_index]
                        winning_announcement = announcement_seq[announcement_index]
                        announcements_thus_far = announcements_so_far.copy()
                        found_winner = True
                    del boards[board_index]
                    deleted_a_board = True
                    won_by_row = True
                    num_boards_left -= 1
            if not won_by_row:
                for column_index in range(num_columns):
                    column_compatible = True
                    for row in boards[board_index]:
                        if row[column_index] not in announcements_so_far:
                            column_compatible = False
                            break
                    if column_compatible:
                        if not found_winner:
                            winning_board = boards[board_index]
                            winning_announcement = announcement_seq[announcement_index]
                            announcements_thus_far = announcements_so_far.copy()
                            found_winner = True
                        deleted_a_board = True
                        num_boards_left -= 1
            if not deleted_a_board:
                board_index += 1
    return (winning_board, winning_announcement, announcements_thus_far, losing_board)

def score_board(board, winning_announcement, announcements_thus_far):
    unmarked_numbers = list()
    for row in board:
        for num in row:
            if num not in announcements_thus_far:
                unmarked_numbers.append(num)
    return int(winning_announcement) * sum(map(int, unmarked_numbers))

winning_board, last_number_called, announcements, losing_board = find_result(boards, announcement_seq)
print(score_board(winning_board, last_number_called, announcements))
print(score_board(losing_board, announcement_seq[-1], set(announcement_seq)))
