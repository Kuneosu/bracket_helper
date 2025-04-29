# badminton_gui_complete.py
# ──────────────────────────────────────────────────────────
import random, math
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ──────────────────────────────────────────────────────────
# 1. '1인당 4게임' 완전 스케줄러
# ──────────────────────────────────────────────────────────
def generate_complete_schedule(num_players: int,
                               games_per_player: int = 4,
                               seed: int | None = None):
    if num_players < 4 or num_players > 32:
        raise ValueError("인원 수는 4~32명만 지원합니다.")

    rng        = random.Random(seed)
    players    = [f"P{i+1}" for i in range(num_players)]
    max_parallel = max(1, num_players // 4)          # 슬롯 당 경기 수

    # 최소 필요 중복 = ceil(12 / (N-1)) (4게임×3명 팀/상대)
    overlap_limit = max(2, math.ceil(12 / (num_players - 1)))

    remain_games = {p: games_per_player for p in players}
    pair_cnt     = defaultdict(lambda: defaultdict(int))
    schedule     = []
    total_games  = num_players * games_per_player // 4

    def ok_group(g):
        return all(pair_cnt[a][b] < overlap_limit
                   for a, b in combinations(g, 2))

    def score(g):
        return sum(pair_cnt[a][b] for a, b in combinations(g, 2))

    while len(schedule) < total_games:
        needers = [p for p in players if remain_games[p] > 0]
        if len(needers) < 4:
            to_add = 4 - len(needers)
            needers += sorted(players, key=lambda x: remain_games[x])[:to_add]

        cand = list(combinations(needers, 4))
        rng.shuffle(cand)
        cand.sort(key=lambda g: (score(g), -sum(remain_games[p] for p in g)))

        group = next((g for g in cand if ok_group(g)), None)
        if group is None:            # 한도를 늘려 재시도
            overlap_limit += 1
            continue

        team = list(group); rng.shuffle(team)
        schedule.append((tuple(team[:2]), tuple(team[2:])))

        for a, b in combinations(group, 2):
            pair_cnt[a][b] += 1; pair_cnt[b][a] += 1
        for p in group:
            remain_games[p] -= 1

    # 슬롯 재구성
    time_slots, slot, used = [], [], set()
    for gm in schedule:
        gset = set(gm[0] + gm[1])
        if (used & gset) or len(slot) >= max_parallel:
            time_slots.append(slot); slot, used = [], set()
        slot.append(gm); used |= gset
    if slot: time_slots.append(slot)

    # 통계
    vals = [v for d in pair_cnt.values() for v in d.values()]
    stats = {"max": max(vals), "avg": round(sum(vals)/len(vals),2),
             "limit": overlap_limit}

    return schedule, time_slots, stats, players

# ──────────────────────────────────────────────────────────
# 2. 히트맵 그리기
# ──────────────────────────────────────────────────────────
def show_heatmap(schedule):
    if not schedule:
        messagebox.showinfo("알림","먼저 대진표를 생성하세요.")
        return
    pair = defaultdict(lambda: defaultdict(int))
    all_p=set()
    for t1,t2 in schedule:
        g=list(t1+t2); all_p.update(g)
        for i in range(4):
            for j in range(i+1,4):
                a,b=g[i],g[j]; pair[a][b]+=1; pair[b][a]+=1
    all_p=sorted(all_p)
    df=pd.DataFrame(0,index=all_p,columns=all_p)
    for a in all_p:
        for b in all_p:
            if a!=b: df.loc[a,b]=pair[a][b]
    plt.figure(figsize=(8,6))
    sns.heatmap(df,annot=True,cmap='YlGnBu',fmt='d',cbar=True)
    plt.title("플레이어 간 중복 히트맵"); plt.tight_layout(); plt.show()

# ──────────────────────────────────────────────────────────
# 3. GUI 상태 전역
# ──────────────────────────────────────────────────────────
schedule, slots, players = [], [], []
wait_list, playing_list = [], []
cur_slot = 0

# ──────────────────────────────────────────────────────────
# 4. GUI 동작
# ──────────────────────────────────────────────────────────
def make_schedule():
    global schedule, slots, players, wait_list, playing_list, cur_slot
    try:
        n = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류","숫자를 입력해주세요."); return
    if n<4 or n>32:
        messagebox.showerror("입력 오류","4~32명만 가능합니다."); return

    schedule, slots, stats, players = generate_complete_schedule(n)
    text.delete("1.0",tk.END)
    for i,(t1,t2) in enumerate(schedule,1):
        text.insert(tk.END,f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")

    # 통계 표시
    stat_lbl.config(text=f"중복 max {stats['max']}회 / 평균 {stats['avg']}")
    if stats['limit']>2:
        messagebox.showwarning("알림",
            f"{n}명 환경에서는 같은 상대를 최대 2회로 제한할 수 없어 "
            f"{stats['limit']}회까지 허용했습니다.")

    wait_list[:] = players[:]; playing_list.clear(); cur_slot = 0
    log.delete("1.0",tk.END)

def run_slot():
    global cur_slot
    if cur_slot>=len(slots):
        log.insert(tk.END,"🏁 모든 경기가 끝났습니다.\n"); return
    slot=slots[cur_slot]
    log.insert(tk.END,f"=== Slot {cur_slot+1} 시작 ===\n")
    playing=[]
    for t1,t2 in slot:
        grp=list(t1+t2)
        for p in grp:
            if p in wait_list:
                wait_list.remove(p); playing_list.append(p)
        playing.append(grp)
        log.insert(tk.END,f"▶ 진행: {', '.join(grp)}\n")
    log.insert(tk.END,f"대기: {', '.join(wait_list) or '없음'}\n\n")
    log.see(tk.END)
    root.after(4000,lambda: finish_slot(playing))

def finish_slot(playing):
    global cur_slot
    for grp in playing:
        for p in grp:
            if p in playing_list:
                playing_list.remove(p); wait_list.append(p)
        log.insert(tk.END,f"✔ 종료: {', '.join(grp)}\n")
    log.insert(tk.END,f"현재 대기: {', '.join(wait_list)}\n\n")
    log.see(tk.END)
    cur_slot+=1
    root.after(600,run_slot)

def start_sim():
    if not schedule: messagebox.showinfo("알림","먼저 대진표를 생성하세요."); return
    log.delete("1.0",tk.END); run_slot()

def heatmap_btn():
    show_heatmap(schedule)

# ──────────────────────────────────────────────────────────
# 5. Tkinter UI
# ──────────────────────────────────────────────────────────
root = tk.Tk(); root.title("완전 4‑게임 배드민턴 스케줄러")

top=tk.Frame(root); top.pack(pady=10)
tk.Label(top,text="참가 인원 (4~32):").pack(side=tk.LEFT)
entry=tk.Entry(top,width=5); entry.pack(side=tk.LEFT)
tk.Button(top,text="대진표 생성",command=make_schedule)\
    .pack(side=tk.LEFT,padx=8)

tk.Button(root,text="히트맵 보기",command=heatmap_btn).pack(pady=4)
tk.Button(root,text="시뮬레이션 시작",command=start_sim).pack(pady=4)

text=tk.Text(root,height=15,width=60); text.pack(pady=6)
stat_lbl=tk.Label(root,text="중복 통계: -"); stat_lbl.pack()
tk.Label(root,text="시뮬레이션 로그").pack()
log=tk.Text(root,height=15,width=60,fg="green"); log.pack(pady=4)

root.mainloop()

