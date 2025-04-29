
import tkinter as tk
from tkinter import messagebox
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import random
from itertools import combinations
from collections import defaultdict

# ===== 안정적인 중복 최소화 알고리즘 =====

def generate_stable_low_overlap_schedule(num_players, max_pair_overlap=2, max_attempts=1):
    players = [f"P{i+1}" for i in range(num_players)]
    required_games_per_player = 4
    total_participations_needed = num_players * required_games_per_player
    max_parallel_games = num_players // 4
    all_combinations = list(combinations(players, 4))

    best_schedule = None
    best_score = float('inf')

    for _ in range(max_attempts):
        player_game_count = defaultdict(int)
        played_with = defaultdict(lambda: defaultdict(int))
        scheduled_games = []

        def calculate_overlap_score(group):
            return sum((played_with[a][b] ** 2) for i, a in enumerate(group) for b in group[i+1:])

        def add_game(group):
            for i in range(4):
                for j in range(i + 1, 4):
                    played_with[group[i]][group[j]] += 1
                    played_with[group[j]][group[i]] += 1
            for p in group:
                player_game_count[p] += 1
            scheduled_games.append(group)

        while sum(player_game_count.values()) < total_participations_needed:
            slot_games = []
            used_players = set()
            sorted_groups = sorted(all_combinations, key=calculate_overlap_score)
            for group in sorted_groups:
                if len(slot_games) >= max_parallel_games:
                    break
                if any(p in used_players for p in group):
                    continue
                if all(player_game_count[p] < required_games_per_player for p in group):
                    slot_games.append(group)
                    used_players.update(group)
            if not slot_games:
                break
            for group in slot_games:
                add_game(group)

        while any(player_game_count[p] < required_games_per_player for p in players):
            for p in players:
                if player_game_count[p] < required_games_per_player:
                    for group in sorted(all_combinations, key=calculate_overlap_score):
                        if p in group and all(player_game_count[x] < required_games_per_player for x in group):
                            add_game(group)
                            break
                    break

        overlap_values = []
        for a in players:
            for b in players:
                if a != b:
                    overlap_values.append(played_with[a][b])
        total_score = sum(overlap_values)

        if total_score < best_score:
            best_score = total_score
            best_schedule = list(scheduled_games)

    final_result = [(group[:2], group[2:]) for group in best_schedule]
    return final_result, players

def count_meeting_overlap(schedule):
    meeting_count = defaultdict(lambda: defaultdict(int))
    for team1, team2 in schedule:
        group = list(team1 + team2)
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                a, b = group[i], group[j]
                meeting_count[a][b] += 1
                meeting_count[b][a] += 1
    all_pairs = set()
    overlap_values = []
    for a in meeting_count:
        for b in meeting_count[a]:
            if (b, a) not in all_pairs:
                all_pairs.add((a, b))
                overlap_values.append(meeting_count[a][b])
    return {
        "max": max(overlap_values),
        "avg": round(sum(overlap_values) / len(overlap_values), 2),
        "total_pairs": len(overlap_values)
    }

def show_heatmap():
    if not schedule:
        messagebox.showinfo("알림", "먼저 대진표를 생성해주세요.")
        return
    meeting_count = defaultdict(lambda: defaultdict(int))
    all_players = set()
    for team1, team2 in schedule:
        group = list(team1 + team2)
        all_players.update(group)
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                a, b = group[i], group[j]
                meeting_count[a][b] += 1
                meeting_count[b][a] += 1
    sorted_players = sorted(all_players)
    matrix = pd.DataFrame(0, index=sorted_players, columns=sorted_players)
    for a in sorted_players:
        for b in sorted_players:
            if a != b:
                matrix.loc[a, b] = meeting_count[a][b]
    plt.figure(figsize=(8, 6))
    sns.heatmap(matrix, annot=True, cmap="YlGnBu", fmt="d", cbar=True)
    plt.title("플레이어 간 중복 매칭 히트맵")
    plt.xlabel("Player")
    plt.ylabel("Player")
    plt.tight_layout()
    plt.show()

# ===== GUI 및 시뮬레이션 =====

schedule = []
players = []
wait_list = []
playing_list = []
time_slots = []
current_slot_index = 0

def display_schedule():
    global schedule, players, wait_list, playing_list, time_slots, current_slot_index
    try:
        num_players = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력해주세요.")
        return
    if num_players < 4 or num_players > 32:
        messagebox.showerror("입력 오류", "인원 수는 4 이상 32 이하만 가능합니다.")
        return

    schedule, players = generate_stable_low_overlap_schedule(num_players)
    wait_list = players.copy()
    playing_list.clear()
    time_slots.clear()
    current_slot_index = 0

    max_parallel = num_players // 4
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

    stats = count_meeting_overlap(schedule)
    stats_label.config(text=f"중복 매칭 통계 → 최대: {stats['max']}회, 평균: {stats['avg']}회, 총 쌍: {stats['total_pairs']}")

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

# ===== GUI 구성 =====

root = tk.Tk()
root.title("안정적 중복 최소화 배드민턴 시뮬레이터")

frame = tk.Frame(root)
frame.pack(pady=10)

label = tk.Label(frame, text="참가 인원 수 (4~32):")
label.pack(side=tk.LEFT)

entry = tk.Entry(frame, width=5)
entry.pack(side=tk.LEFT)

button = tk.Button(frame, text="대진표 생성", command=display_schedule)
button.pack(side=tk.LEFT, padx=10)

heatmap_button = tk.Button(root, text="히트맵 보기", command=show_heatmap)
heatmap_button.pack(pady=5)

simulate_button = tk.Button(root, text="게임 시뮬레이션 시작", command=start_simulation)
simulate_button.pack(pady=5)

text_area = tk.Text(root, height=15, width=60)
text_area.pack(pady=10)

stats_label = tk.Label(root, text="중복 매칭 통계 → 최대: -, 평균: -, 총 쌍: -")
stats_label.pack()

status_label = tk.Label(root, text="게임 시뮬레이션 상태:")
status_label.pack()

status_text = tk.Text(root, height=15, width=60, fg="green")
status_text.pack(pady=5)

root.mainloop()
