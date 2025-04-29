
import tkinter as tk
from tkinter import messagebox
import random
from itertools import combinations
from collections import defaultdict

def generate_fully_guaranteed_schedule(num_players):
    if num_players < 4 or num_players > 32:
        return []

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

    # 1단계: 이상적 조합 우선
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

    # 2단계: 조건 완화
    for group in possible_groups:
        if len(games) >= total_games_needed:
            break
        if frozenset(group) in used_groups:
            continue
        if any(game_count[p] >= 4 for p in group):
            continue
        used_groups.add(frozenset(group))
        register_game(group)

    # 3단계: 무조건 추가
    while len(games) < total_games_needed:
        for group in possible_groups:
            register_game(group, ignore_limits=True)
            if len(games) >= total_games_needed:
                break

    return games

def display_schedule():
    try:
        num_players = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력해주세요.")
        return

    schedule = generate_fully_guaranteed_schedule(num_players)
    if not schedule:
        messagebox.showerror("오류", "인원 수는 4 이상 32 이하만 가능합니다.")
        return

    text_area.delete("1.0", tk.END)
    for idx, (team1, team2) in enumerate(schedule, start=1):
        game_text = f"Game {idx}: {', '.join(team1)} vs {', '.join(team2)}\n"
        text_area.insert(tk.END, game_text)

# GUI 구성
root = tk.Tk()
root.title("배드민턴 대진표 생성기")

frame = tk.Frame(root)
frame.pack(pady=10)

label = tk.Label(frame, text="참가 인원 수 (4~32):")
label.pack(side=tk.LEFT)

entry = tk.Entry(frame, width=5)
entry.pack(side=tk.LEFT)

button = tk.Button(frame, text="대진표 생성", command=display_schedule)
button.pack(side=tk.LEFT, padx=10)

text_area = tk.Text(root, height=25, width=55)
text_area.pack(pady=10)

root.mainloop()
