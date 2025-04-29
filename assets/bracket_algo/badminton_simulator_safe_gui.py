
import tkinter as tk
from tkinter import messagebox
import random
from itertools import combinations
from collections import defaultdict

def generate_fully_guaranteed_schedule(num_players):
    if num_players < 4 or num_players > 32:
        return [], []

    players = [f"P{i+1}" for i in range(num_players)]
    total_games_needed = num_players
    game_count = defaultdict(int)
    played_with = defaultdict(set)

    games = []
    used_groups = set()
    possible_groups = list(combinations(players, 4))
    random.shuffle(possible_groups)

    def register_game(group, ignore_limits=False):
        if not ignore_limits:
            for p in group:
                game_count[p] += 1
                played_with[p].update(set(group) - {p})
        team1 = group[:2]
        team2 = group[2:]
        games.append((team1, team2))

    for group in possible_groups:
        if len(games) >= total_games_needed:
            break
        if frozenset(group) in used_groups:
            continue
        if any(game_count[p] >= 4 for p in group):
            continue
        overlap = sum(1 for i in range(4) for j in range(i+1, 4) if group[j] in played_with[group[i]])
        if overlap <= 2:
            used_groups.add(frozenset(group))
            register_game(group)

    for group in possible_groups:
        if len(games) >= total_games_needed:
            break
        if frozenset(group) in used_groups:
            continue
        if any(game_count[p] >= 4 for p in group):
            continue
        used_groups.add(frozenset(group))
        register_game(group)

    while len(games) < total_games_needed:
        for group in possible_groups:
            register_game(group, ignore_limits=True)
            if len(games) >= total_games_needed:
                break

    return games, players

# 상태 변수
schedule = []
players = []
wait_list = []
playing_list = []
current_game_index = 0

def display_schedule():
    global schedule, players, wait_list, current_game_index
    try:
        num_players = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력해주세요.")
        return

    schedule, players = generate_fully_guaranteed_schedule(num_players)
    if not schedule:
        messagebox.showerror("오류", "인원 수는 4 이상 32 이하만 가능합니다.")
        return

    wait_list = players.copy()
    current_game_index = 0

    text_area.delete("1.0", tk.END)
    for idx, (team1, team2) in enumerate(schedule, start=1):
        game_text = f"Game {idx}: {', '.join(team1)} vs {', '.join(team2)}\n"
        text_area.insert(tk.END, game_text)

def simulate_next_game():
    global current_game_index, wait_list, playing_list

    if current_game_index >= len(schedule):
        status_text.insert(tk.END, "🏁 모든 게임이 완료되었습니다.\n")
        return

    team1, team2 = schedule[current_game_index]
    game_players = list(team1 + team2)

    for p in game_players:
        if p in wait_list:
            wait_list.remove(p)
            playing_list.append(p)

    status_text.insert(tk.END, f"▶ Game {current_game_index + 1} 진행 중: {', '.join(game_players)}\n")
    status_text.insert(tk.END, f"   대기 인원: {', '.join(wait_list)}\n\n")
    status_text.see(tk.END)

    # 게임 5초 후 종료 처리 예약
    root.after(5000, finish_current_game, game_players)

def finish_current_game(game_players):
    global current_game_index, wait_list, playing_list

    for p in game_players:
        if p in playing_list:
            playing_list.remove(p)
            wait_list.append(p)

    status_text.insert(tk.END, f"✔ Game {current_game_index + 1} 종료\n")
    status_text.insert(tk.END, f"   현재 대기 인원: {', '.join(wait_list)}\n\n")
    status_text.see(tk.END)
    current_game_index += 1
    root.after(500, simulate_next_game)

def start_simulation():
    status_text.delete("1.0", tk.END)
    simulate_next_game()

# GUI 구성
root = tk.Tk()
root.title("배드민턴 대진표 시뮬레이터 (macOS 안전버전)")

frame = tk.Frame(root)
frame.pack(pady=10)

label = tk.Label(frame, text="참가 인원 수 (4~32):")
label.pack(side=tk.LEFT)

entry = tk.Entry(frame, width=5)
entry.pack(side=tk.LEFT)

button = tk.Button(frame, text="대진표 생성", command=display_schedule)
button.pack(side=tk.LEFT, padx=10)

simulate_button = tk.Button(root, text="게임 시뮬레이션 시작", command=start_simulation)
simulate_button.pack(pady=5)

text_area = tk.Text(root, height=15, width=60)
text_area.pack(pady=10)

status_label = tk.Label(root, text="게임 시뮬레이션 상태:")
status_label.pack()

status_text = tk.Text(root, height=15, width=60, fg="green")
status_text.pack(pady=5)

root.mainloop()
