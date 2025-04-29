# badminton_gui_slot_first.py
# ---------------------------------------------
# 필요한 패키지: matplotlib, seaborn, pandas
# 설치: pip install matplotlib seaborn pandas
# ---------------------------------------------
import tkinter as tk
from tkinter import messagebox
import random, math
from itertools import combinations
from collections import defaultdict
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ──────────────────────────────────────────
# 1. 슬롯‑우선 배드민턴 대진표 알고리즘
# ──────────────────────────────────────────
def generate_slot_first_schedule(num_players,
                                 games_per_player=4,
                                 base_pair_overlap=2,
                                 seed=None):
    """
    num_players : 4~32 (짝/홀 모두)
    base_pair_overlap : '가능하면' 지킬 최대 중복값.
                        이론적으로 4~6명은 2회를 만족할 수 없으므로
                        함수 내부에서 자동 보정.
    """
    # 이론적 최소 중복 횟수 = ceil(12 / (N-1))
    min_needed = math.ceil(12 / (num_players - 1))
    max_pair_overlap = max(base_pair_overlap, min_needed)

    rng = random.Random(seed)
    players = [f"P{i+1}" for i in range(num_players)]
    max_parallel = max(1, num_players // 4)   # 슬롯 당 동시 경기 수 (최소 1)

    remain      = {p: games_per_player for p in players}
    pair_cnt    = defaultdict(lambda: defaultdict(int))

    schedule, slot_map = [], []              # 전체 경기, 슬롯별 경기

    def valid_group(g):
        return all(pair_cnt[a][b] < max_pair_overlap
                   for a, b in combinations(g, 2))
    def overlap_score(g):
        return sum(pair_cnt[a][b] for a,b in combinations(g,2))

    while any(remain[p] > 0 for p in players):
        used_in_slot, games_this_slot = set(), []

        while len(games_this_slot) < max_parallel:
            cands = [p for p in players if remain[p] > 0 and p not in used_in_slot]
            if len(cands) < 4:
                break                                     # 더 이상 조합 불가 → 슬롯 종료

            best, best_score = None, 10**9
            rng.shuffle(cands)
            for g in combinations(cands,4):
                if not valid_group(g):
                    continue
                sc = overlap_score(g)
                if sc < best_score:
                    best, best_score = g, sc
                    if sc == 0:
                        break
            if best is None:                              # 제약으로 그룹 미선택 → 슬롯 종료
                break

            perm  = rng.sample(best,4)                    # 2:2 팀 랜덤 배정
            team1, team2 = tuple(perm[:2]), tuple(perm[2:])
            games_this_slot.append((team1, team2))

            for a,b in combinations(best,2):
                pair_cnt[a][b] += 1
                pair_cnt[b][a] += 1
            for p in best:
                remain[p] -= 1
                used_in_slot.add(p)

        if not games_this_slot:                           # 더 이상 만들 수 없으면 루프 탈출
            break
        slot_map.append(games_this_slot)
        schedule.extend(games_this_slot)

    return schedule, slot_map, players, max_pair_overlap

# ──────────────────────────────────────────
# 2. 통계 & 히트맵 유틸
# ──────────────────────────────────────────
def count_meeting_overlap(schedule):
    meet = defaultdict(lambda: defaultdict(int))
    for t1, t2 in schedule:
        group = list(t1+t2)
        for i in range(len(group)):
            for j in range(i+1,len(group)):
                a,b = group[i], group[j]
                meet[a][b]+=1; meet[b][a]+=1
    vals=[v for d in meet.values() for v in d.values()]
    return {"max": max(vals), "avg": round(sum(vals)/len(vals),2),
            "total_pairs": len(vals)}

def show_heatmap(schedule):
    if not schedule:
        messagebox.showinfo("알림","먼저 대진표를 생성하세요.")
        return
    meet = defaultdict(lambda: defaultdict(int))
    players=set()
    for t1,t2 in schedule:
        group=list(t1+t2)
        players.update(group)
        for i in range(len(group)):
            for j in range(i+1,len(group)):
                a,b=group[i],group[j]
                meet[a][b]+=1; meet[b][a]+=1
    players=sorted(players)
    df=pd.DataFrame(0,index=players,columns=players)
    for a in players:
        for b in players:
            if a!=b: df.loc[a,b]=meet[a][b]
    plt.figure(figsize=(8,6))
    sns.heatmap(df,annot=True,cmap="YlGnBu",fmt="d",cbar=True)
    plt.title("플레이어 간 중복 매칭 히트맵")
    plt.tight_layout(); plt.show()

# ──────────────────────────────────────────
# 3. GUI & 시뮬레이션 상태 전역
# ──────────────────────────────────────────
schedule      = []      # 전체 경기 목록 [(team1,team2), ...]
time_slots    = []      # 슬롯별 경기 리스트 [[(t1,t2),...], ...]
players       = []      # 참가자 이름 리스트
wait_list     = []      # 대기 중인 플레이어
playing_list  = []      # 현재 경기 중 플레이어
current_slot  = 0       # 진행 중인 슬롯 인덱스
effective_overlap = 2   # 실제 사용된 최대 허용 중복값

# ──────────────────────────────────────────
# 4. GUI 함수
# ──────────────────────────────────────────
def display_schedule():
    global schedule, time_slots, players, wait_list
    global playing_list, current_slot, effective_overlap
    try:
        n=int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류","숫자를 입력하세요.")
        return
    if n < 4 or n > 32:
        messagebox.showerror("입력 오류","4부터 32 사이 인원만 가능합니다.")
        return

    schedule, time_slots, players, effective_overlap \
        = generate_slot_first_schedule(n)
    wait_list[:] = players[:]
    playing_list.clear()
    current_slot = 0

    text_area.delete("1.0",tk.END)
    for idx,(t1,t2) in enumerate(schedule,1):
        text_area.insert(tk.END,
            f"Game {idx}: {', '.join(t1)} vs {', '.join(t2)}\n")

    if effective_overlap > 2:
        messagebox.showwarning(
            "알림",
            f"{n}명은 같은 상대를 최대 2회로 막을 수 없습니다.\n"
            f"최소 {effective_overlap}회까지 허용으로 자동 보정했습니다."
        )

    stats = count_meeting_overlap(schedule)
    stats_label.config(text=f"중복 통계 → 최대 {stats['max']}회, "
                            f"평균 {stats['avg']}회, 쌍 {stats['total_pairs']}")

def simulate_slot():
    global current_slot
    if current_slot>=len(time_slots):
        status_text.insert(tk.END,"🏁 모든 경기가 끝났습니다.\n")
        return
    slot   = time_slots[current_slot]
    status_text.insert(tk.END,f"=== Slot {current_slot+1} 시작 ===\n")
    playing=[]

    for t1,t2 in slot:
        group=list(t1+t2)
        for p in group:
            if p in wait_list:
                wait_list.remove(p); playing_list.append(p)
        playing.append(group)
        status_text.insert(tk.END,f"▶ 진행: {', '.join(group)}\n")

    status_text.insert(tk.END,
        f"대기: {', '.join(wait_list) if wait_list else '없음'}\n\n")
    status_text.see(tk.END)

    root.after(4000, lambda: finish_slot(playing))

def finish_slot(playing):
    global current_slot
    for group in playing:
        for p in group:
            if p in playing_list:
                playing_list.remove(p); wait_list.append(p)
        status_text.insert(tk.END,f"✔ 종료: {', '.join(group)}\n")
    status_text.insert(tk.END,
        f"현재 대기: {', '.join(wait_list)}\n\n")
    status_text.see(tk.END)
    current_slot += 1
    root.after(600, simulate_slot)

def start_simulation():
    status_text.delete("1.0",tk.END)
    simulate_slot()

def open_heatmap():
    show_heatmap(schedule)

# ──────────────────────────────────────────
# 5. Tk 인터페이스 구성
# ──────────────────────────────────────────
root = tk.Tk(); root.title("슬롯‑우선 배드민턴 시뮬레이터")

top = tk.Frame(root); top.pack(pady=10)
tk.Label(top,text="참가 인원 (4~32):").pack(side=tk.LEFT)
entry=tk.Entry(top,width=5); entry.pack(side=tk.LEFT)
tk.Button(top,text="대진표 생성",command=display_schedule)\
    .pack(side=tk.LEFT,padx=8)

tk.Button(root,text="히트맵 보기",command=open_heatmap).pack(pady=4)
tk.Button(root,text="게임 시뮬레이션 시작",command=start_simulation).pack(pady=4)

text_area=tk.Text(root,height=15,width=60); text_area.pack(pady=8)
stats_label=tk.Label(root,text="중복 통계 → -"); stats_label.pack()

tk.Label(root,text="시뮬레이션 로그").pack()
status_text=tk.Text(root,height=15,width=60,fg="green"); status_text.pack(pady=4)

root.mainloop()

