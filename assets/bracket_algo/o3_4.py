# badminton_gui_strict2.py  (Python ≥3.10)
# 필요 패키지: matplotlib seaborn pandas
# ---------------------------------------------
import random, math
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ──────────────────────────────────────────────
# 1. 1인당 4경기 + ‘최대 2회’ 강제 스케줄러
# ──────────────────────────────────────────────
def _try_make_schedule(num_players: int,
                       games_per: int,
                       pair_limit: int,
                       rng: random.Random):
    """pair_limit 을 넘지 않으면서 스케줄 생성, 실패 시 None 반환."""
    players  = [f"P{i+1}" for i in range(num_players)]
    total_g  = num_players * games_per // 4
    remain   = {p: games_per for p in players}
    pair_cnt = defaultdict(lambda: defaultdict(int))
    sched    = []

    def ok_group(g):
        return all(pair_cnt[a][b] < pair_limit for a,b in combinations(g,2))
    def score(g):
        return sum(pair_cnt[a][b] for a,b in combinations(g,2))

    while len(sched) < total_g:
        needers = [p for p in players if remain[p] > 0]
        if len(needers) < 4:
            needers += sorted(players, key=lambda x: remain[x])[:4-len(needers)]

        cands   = list(combinations(needers,4))
        rng.shuffle(cands)
        cands.sort(key=lambda g:(score(g), -sum(remain[p] for p in g)))
        group   = next((g for g in cands if ok_group(g)), None)
        if group is None:
            return None        # 이번 시드로는 실패
        team = list(group); rng.shuffle(team)
        sched.append((tuple(team[:2]), tuple(team[2:])))
        for a,b in combinations(group,2):
            pair_cnt[a][b]+=1; pair_cnt[b][a]+=1
        for p in group:
            remain[p]-=1
    return sched, pair_cnt

def generate_schedule_strict(num_players: int,
                             games_per_player: int = 4,
                             max_retry: int = 3000):
    """무조건 ‘최대 2회’(가능한 인원 한정) 스케줄을 찾아 반환."""
    if num_players < 4 or num_players > 32:
        raise ValueError("인원 수는 4~32 명만 지원합니다.")
    theoretical_min = math.ceil(12 / (num_players - 1))
    strict2_possible = theoretical_min <= 2

    # strict2 가능한 경우 → 시드를 바꿔가며 2회짜리 스케줄 탐색
    if strict2_possible:
        rng = random.Random()
        for _ in range(max_retry):
            seed = rng.randrange(1<<30)
            rsched = _try_make_schedule(num_players, games_per_player, 2,
                                        random.Random(seed))
            if rsched:
                schedule, pair_cnt = rsched
                break
        else:
            raise RuntimeError("조건(최대 2회)을 만족하는 대진표를 찾지 못했습니다.")
        pair_limit_used = 2
    # 불가능한 인원 → 최소 가능 한도(3회·4회 …)로 한 번에 생성
    else:
        pair_limit_used = theoretical_min
        rsched = _try_make_schedule(num_players, games_per_player,
                                    pair_limit_used, random.Random())
        if not rsched:
            raise RuntimeError("대진표 생성 실패(알고리즘 오류).")
        schedule, pair_cnt = rsched

    # 슬롯 구성
    max_parallel = max(1, num_players // 4)
    slots, slot, used = [], [], set()
    for gm in schedule:
        gset = set(gm[0] + gm[1])
        if (used & gset) or len(slot) >= max_parallel:
            slots.append(slot); slot, used = [], set()
        slot.append(gm); used |= gset
    if slot: slots.append(slot)

    # 통계
    vals = [v for d in pair_cnt.values() for v in d.values()]
    stats = {"max": max(vals), "avg": round(sum(vals)/len(vals),2),
             "limit": pair_limit_used}
    return schedule, slots, stats, [f"P{i+1}" for i in range(num_players)]

# ──────────────────────────────────────────────
# 2. 히트맵
# ──────────────────────────────────────────────
def show_heatmap(schedule):
    if not schedule:
        messagebox.showinfo("알림","먼저 대진표를 생성하세요."); return
    pair = defaultdict(lambda: defaultdict(int))
    ps=set()
    for t1,t2 in schedule:
        g=list(t1+t2); ps.update(g)
        for i in range(4):
            for j in range(i+1,4):
                a,b=g[i],g[j]; pair[a][b]+=1; pair[b][a]+=1
    ps=sorted(ps)
    df=pd.DataFrame(0,index=ps,columns=ps)
    for a in ps:
        for b in ps:
            if a!=b: df.loc[a,b]=pair[a][b]
    plt.figure(figsize=(8,6))
    sns.heatmap(df,annot=True,cmap='YlGnBu',fmt='d',cbar=True)
    plt.title("플레이어 간 중복 히트맵"); plt.tight_layout(); plt.show()

# ──────────────────────────────────────────────
# 3. GUI 상태
# ──────────────────────────────────────────────
schedule, slots, players = [], [], []
wait_list, playing = [], []
cur_slot = 0

# ──────────────────────────────────────────────
# 4. GUI 동작
# ──────────────────────────────────────────────
def make_schedule():
    global schedule, slots, players, wait_list, playing, cur_slot
    try: n=int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류","숫자를 입력하세요."); return
    if n<4 or n>32:
        messagebox.showerror("입력 오류","4~32 명만 가능합니다."); return

    try:
        schedule, slots, stats, players \
            = generate_schedule_strict(n)
    except RuntimeError as e:
        messagebox.showerror("생성 실패", str(e)); return

    text.delete("1.0",tk.END)
    for i,(t1,t2) in enumerate(schedule,1):
        text.insert(tk.END,f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")

    stat_lbl.config(text=f"max {stats['max']}회 / avg {stats['avg']}회 "
                         f"(허용 {stats['limit']})")
    if stats['limit']>2:
        messagebox.showwarning("알림",
            f"{n}명은 이론적으로 2회 제한이 불가 → "
            f"최소 {stats['limit']}회까지 허용했습니다.")

    wait_list[:] = players[:]; playing.clear(); cur_slot=0
    log.delete("1.0",tk.END)

def run_slot():
    global cur_slot
    if cur_slot>=len(slots):
        log.insert(tk.END,"🏁 종료.\n"); return
    slot=slots[cur_slot]
    log.insert(tk.END,f"=== Slot {cur_slot+1} ===\n")
    p_in_slot=[]
    for t1,t2 in slot:
        g=list(t1+t2); p_in_slot+=g
        for p in g:
            if p in wait_list: wait_list.remove(p); playing.append(p)
        log.insert(tk.END,f"▶ {' & '.join(t1)}  vs  {' & '.join(t2)}\n")
    log.insert(tk.END,f"대기: {', '.join(wait_list) or '없음'}\n\n")
    log.see(tk.END)
    root.after(4000, lambda: finish_slot(p_in_slot))

def finish_slot(players_done):
    global cur_slot
    for p in players_done:
        if p in playing: playing.remove(p); wait_list.append(p)
    log.insert(tk.END,f"✔ 종료: {', '.join(players_done)}\n\n")
    log.see(tk.END)
    cur_slot+=1
    root.after(600, run_slot)

def start_sim():
    if not schedule: messagebox.showinfo("알림","먼저 대진표를 생성하세요."); return
    log.delete("1.0",tk.END); run_slot()

# 히트맵 버튼
def open_heat():
    show_heatmap(schedule)

# ──────────────────────────────────────────────
# 5. Tk 인터페이스
# ──────────────────────────────────────────────
root=tk.Tk(); root.title("배드민턴 4‑게임 스케줄러 (최대 2회 중복)")

top=tk.Frame(root); top.pack(pady=10)
tk.Label(top,text="참가 인원 (4~32):").pack(side=tk.LEFT)
entry=tk.Entry(top,width=5); entry.pack(side=tk.LEFT)
tk.Button(top,text="대진표 생성",command=make_schedule)\
    .pack(side=tk.LEFT,padx=8)

tk.Button(root,text="히트맵 보기",command=open_heat).pack(pady=4)
tk.Button(root,text="시뮬레이션 시작",command=start_sim).pack(pady=4)

text=tk.Text(root,height=15,width=60); text.pack(pady=6)
stat_lbl=tk.Label(root,text="중복 통계: -"); stat_lbl.pack()
tk.Label(root,text="시뮬레이션").pack()
log=tk.Text(root,height=15,width=60,fg="green"); log.pack(pady=4)

root.mainloop()

