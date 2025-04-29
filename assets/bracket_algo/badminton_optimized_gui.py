
import tkinter as tk
from tkinter import messagebox
import random
from itertools import combinations
from collections import defaultdict

def generate_optimized_parallel_schedule(num_players):
    if num_players < 4 or num_players > 32:
        return [], []

    players = [f"P{i+1}" for i in range(num_players)]
    required_games_per_player = 4
    total_games_needed = num_players
    max_parallel_games = num_players // 4

    all_combinations = list(combinations(players, 4))
    player_game_count = defaultdict(int)
    played_with = defaultdict(lambda: defaultdict(int))
    scheduled_games = []

    def calculate_overlap_score(group):
        score = 0
        for i in range(4):
            for j in range(i + 1, 4):
                score += played_with[group[i]][group[j]]
        return score

    def get_sorted_combinations():
        return sorted(all_combinations, key=lambda group: calculate_overlap_score(group))

    def can_schedule(group):
        return all(player_game_count[p] < required_games_per_player for p in group)

    def mark_scheduled(group):
        for i in range(4):
            for j in range(i + 1, 4):
                played_with[group[i]][group[j]] += 1
                played_with[group[j]][group[i]] += 1
        for p in group:
            player_game_count[p] += 1

    while len(scheduled_games) < total_games_needed:
        slot_games = []
        used_players = set()
        for group in get_sorted_combinations():
            if not can_schedule(group):
                continue
            if any(p in used_players for p in group):
                continue
            slot_games.append(group)
            used_players.update(group)
            if len(slot_games) >= max_parallel_games:
                break

        if not slot_games:
            break

        for group in slot_games:
            mark_scheduled(group)
            scheduled_games.append(group)

    remaining = total_games_needed - len(scheduled_games)
    if remaining > 0:
        for group in all_combinations:
            if len(scheduled_games) >= total_games_needed:
                break
            scheduled_games.append(group)

    result = []
    for group in scheduled_games:
        team1 = group[:2]
        team2 = group[2:]
        result.append((team1, team2))

    return result, players

# 상태 변수
schedule = []
players = []
wait_list = []
playing_list = []
finished_games = set()
time_slots = []
current_slot_index = 0

def display_schedule():
    global schedule, players, wait_list, time_slots, current_slot_index
    try:
        num_players = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력해주세요.")
        return

    schedule, players = generate_optimized_parallel_schedule(num_players)
    if not schedule:
        messagebox.showerror("오류", "인원 수는 4 이상 32 이하만 가능합니다.")
        return

    wait_list.clear()
    wait_list.extend(players)
    playing_list.clear()
    finished_games.clear()
    current_slot_index = 0

    # 게임을 slot 단위로 그룹화
    max_parallel = num_players // 4
    time_slots.clear()
    used = set()
    slot = []
    for game in schedule:
        game_players = set(game[0] + game[1])
        if any(p in used for p in game_players):
            time_slots.append(slot)
            slot = []
            used.clear()
        slot.append(game)
        used.update(game_players)
        if len(slot) == max_parallel:
            time_slots.append(slot)
            slot = []
            used.clear()
    if slot:
        time_slots.append(slot)

    text_area.delete("1.0", tk.END)
    for idx, (team1, team2) in enumerate(schedule, start=1):
        text_area.insert(tk.END, f"Game {idx}: {', '.join(team1)} vs {', '.join(team2)}\n")

def simulate_slot():
    global current_slot_index

    if current_slot_index >= len(time_slots):
        status_text.insert(tk.END, "🏁 모든 게임이 완료되었습니다.\n")
        return

    slot = time_slots[current_slot_index]
    playing = []
    for team1, team2 in slot:
        players_in_game = list(team1 + team2)
        for p in players_in_game:
            if p in wait_list:
                wait_list.remove(p)
                playing_list.append(p)
        playing.append(players_in_game)
        status_text.insert(tk.END, f"▶ 진행 중: {', '.join(players_in_game)}\n")

    status_text.insert(tk.END, f"   대기 인원: {', '.join(wait_list)}\n\n")
    status_text.see(tk.END)

    root.after(5000, lambda: finish_slot(playing))

def finish_slot(playing):
    global current_slot_index
    for game_players in playing:
        for p in game_players:
            if p in playing_list:
                playing_list.remove(p)
                wait_list.append(p)
        status_text.insert(tk.END, f"✔ 종료: {', '.join(game_players)}\n")
    status_text.insert(tk.END, f"   현재 대기 인원: {', '.join(wait_list)}\n\n")
    status_text.see(tk.END)

    current_slot_index += 1
    root.after(500, simulate_slot)

def start_simulation():
    status_text.delete("1.0", tk.END)
    simulate_slot()

# GUI 구성
root = tk.Tk()
root.title("배드민턴 대진표 최적화 시뮬레이터")

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
