from sys import argv

class Board:
    def __init__(self, lines):
        self.lines = list(map(lambda line: list(map(int, line.split())), lines))
        self.first_win_length = None

    def _wins_horizontally(self, seq):
        for line in self.lines:
            won = True
            for num in line:
                if num not in seq:
                    won = False
                    break
            if won:
                return True
        return False

    def _wins_vertically(self, seq):
        for i in range(5):
            won = True
            for line in self.lines:
                if line[i] not in seq:
                    won = False
                    break
            if won:
                return True
        return False

    def wins_for_first_time(self, seq):
        if self.first_win_length is not None:
            if len(seq) >= self.first_win_length:
                return False
        won = self._wins_horizontally(seq) or self._wins_vertically(seq)
        if self.first_win_length is None and won:
            self.first_win_length = len(seq)
        return won

    def score(self, seq):
        relevant_seq = seq[:self.first_win_length]
        score = 0
        for line in self.lines:
            for num in line:
                if num not in relevant_seq:
                    score += num
        score *= seq[self.first_win_length - 1]
        return score

def main(file_name):
    with open(file_name, 'r') as f:
        lines = f.readlines()
    seq = list(map(int, lines[0].split(',')))
    
    file_index = 2
    boards = list()
    while True:
        if file_index > len(lines):
            break
        new_lines = lines[file_index:file_index+5]
        boards.append(Board(new_lines))
        file_index += 6

    first_winner = None
    last_winner = None
    for l in range(1, len(seq)):
        for board in boards:
            if board.wins_for_first_time(seq[:l]):
                if first_winner is None:
                    first_winner = board
                last_winner = board

    print(first_winner.score(seq))
    print(last_winner.score(seq))

if __name__ == '__main__':
    if len(argv) != 2:
        print('usage: main.py <file>')
        quit()
    main(argv[1])
