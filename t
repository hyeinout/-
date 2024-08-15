import pygame
import random

pygame.init()
width, height = 300, 600
block_size = 30
cols, rows = width // block_size, height // block_size
screen = pygame.display.set_mode((width, height))
pygame.display.set_caption("Tetris")

colors = [
    (0, 0, 0),      
    (255, 0, 0),    
    (0, 255, 0),    
    (0, 0, 255),    
    (255, 255, 0),
    (255, 0, 255), 
    (0, 255, 255), 
    (192, 192, 192)
]

shapes = [
    ([[1, 1, 1, 1]], 1), 
    ([[1, 1, 1], [0, 1, 0]], 2),  
    ([[1, 1], [1, 1]], 3),  
    ([[1, 1, 0], [0, 1, 1]], 4),  
    ([[0, 1, 1], [1, 1, 0]], 5),  
    ([[1, 1, 1], [1, 0, 0]], 6),  
    ([[1, 1, 1], [0, 0, 1]], 7)  
]

def draw_board(board):
    for y in range(len(board)):
        for x in range(len(board[y])):
            pygame.draw.rect(screen, colors[board[y][x]], pygame.Rect(x * block_size, y * block_size, block_size, block_size))
            pygame.draw.rect(screen, (0, 0, 0), pygame.Rect(x * block_size, y * block_size, block_size, block_size), 1)

def check_collision(board, shape, offset):
    shape_width = len(shape[0])
    shape_height = len(shape)
    x_offset, y_offset = offset
    for y in range(shape_height):
        for x in range(shape_width):
            if shape[y][x]:
                board_x = x + x_offset
                board_y = y + y_offset
                if board_x < 0 or board_x >= cols or board_y >= rows or board[board_y][board_x]:
                    return True
    return False

def merge_shape(board, shape, offset, color_id):
    shape_width = len(shape[0])
    shape_height = len(shape)
    x_offset, y_offset = offset
    for y in range(shape_height):
        for x in range(shape_width):
            if shape[y][x]:
                board[y + y_offset][x + x_offset] = color_id

def clear_lines(board):
    full_lines = [i for i, row in enumerate(board) if all(row)]
    for line in full_lines:
        del board[line]
        board.insert(0, [0] * cols)
    return len(full_lines)

def rotate(shape):
    return [list(row) for row in zip(*shape[::-1])]

def draw_current_shape(board, shape, shape_pos, color_id):
    preview_board = [[0] * cols for _ in range(rows)]
    for y in range(len(shape)):
        for x in range(len(shape[y])):
            if shape[y][x]:
                px = shape_pos[0] + x
                py = shape_pos[1] + y
                if 0 <= px < cols and 0 <= py < rows:
                    preview_board[py][px] = color_id
    draw_board(preview_board)

def main():
    clock = pygame.time.Clock()
    board = [[0] * cols for _ in range(rows)]
    game_over = False
    fall_time = 0
    fall_speed = 500 
    shape, color_id = random.choice(shapes)
    shape_pos = [cols // 2 - len(shape[0]) // 2, 0]

    while not game_over:
        screen.fill((0, 0, 0))
        fall_time += clock.get_rawtime()
        clock.tick()

        if fall_time > fall_speed:
            shape_pos[1] += 1
            if check_collision(board, shape, shape_pos):
                shape_pos[1] -= 1
                merge_shape(board, shape, shape_pos, color_id)
                clear_lines(board)
                shape, color_id = random.choice(shapes)
                shape_pos = [cols // 2 - len(shape[0]) // 2, 0]
                if check_collision(board, shape, shape_pos):
                    game_over = True
            fall_time = 0

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                game_over = True
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    shape_pos[0] -= 1
                    if check_collision(board, shape, shape_pos):
                        shape_pos[0] += 1
                if event.key == pygame.K_RIGHT:
                    shape_pos[0] += 1
                    if check_collision(board, shape, shape_pos):
                        shape_pos[0] -= 1
                if event.key == pygame.K_DOWN:
                    shape_pos[1] += 1
                    if check_collision(board, shape, shape_pos):
                        shape_pos[1] -= 1
                if event.key == pygame.K_UP:
                    rotated_shape = rotate(shape)
                    if not check_collision(board, rotated_shape, shape_pos):
                        shape = rotated_shape

        draw_board(board)
        draw_current_shape(board, shape, shape_pos, color_id)
        pygame.display.flip()

    pygame.quit()

if __name__ == "__main__":
    main()
