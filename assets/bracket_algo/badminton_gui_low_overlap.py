
import tkinter as tk
from tkinter import messagebox
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import random
from itertools import combinations
from collections import defaultdict

# ===== 알고리즘 =====

def generate_low_overlap_schedule(num_players, max_pair_overlap=2):
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
                a, b = group[i], group[j]
                score += played_with[a][b]
        return score

    def can_schedule(group):
        if any(player_game_count[p] >= required_games_per_player for p in group):
            return False
        for i in range(4):
            for j in range(i + 1, 4):
                a, b = group[i], group[j]
                if played_with[a][b] >= max_pair_overlap:
                    return False
        return True

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
        available_groups = sorted(all_combinations, key=lambda g: calculate_overlap_score(g))
        for group in available_groups:
            if len(slot_games) >= max_parallel_games:
                break
            if not can_schedule(group):
                continue
            if any(p in used_players for p in group):
                continue
            mark_scheduled(group)
            slot_games.append(group)
            used_players.update(group)

        if not slot_games:
            break

        scheduled_games.extend(slot_games)

    for group in all_combinations:
        if len(scheduled_games) >= total_games_needed:
            break
        if any(player_game_count[p] >= required_games_per_player for p in group):
            continue
        if any(any(p in g for p in group) for g in scheduled_games[-max_parallel_games:]):
            continue
        mark_scheduled(group)
        scheduled_games.append(group)

    result = []
    for group in scheduled_games:
        team1 = group[:2]
        team2 = group[2:]
        result.append((team1, team2))

    return result

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

# ===== GUI =====

schedule = []

def display_schedule():
    global schedule
    try:
        num_players = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력해주세요.")
        return
    if num_players < 4 or num_players > 32:
        messagebox.showerror("입력 오류", "인원 수는 4 이상 32 이하만 가능합니다.")
        return
    schedule = generate_low_overlap_schedule(num_players)
    text_area.delete("1.0", tk.END)
    for idx, (team1, team2) in enumerate(schedule, start=1):
        text_area.insert(tk.END, f"Game {idx}: {', '.join(team1)} vs {', '.join(team2)}\n")
    stats = count_meeting_overlap(schedule)
    stats_label.config(text=f"중복 매칭 통계 → 최대: {stats['max']}회, 평균: {stats['avg']}회, 총 쌍: {stats['total_pairs']}")

root = tk.Tk()
root.title("중복 제한 배드민턴 대진표 생성기")

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

text_area = tk.Text(root, height=15, width=60)
text_area.pack(pady=10)

stats_label = tk.Label(root, text="중복 매칭 통계 → 최대: -, 평균: -, 총 쌍: -")
stats_label.pack()

root.mainloop()
