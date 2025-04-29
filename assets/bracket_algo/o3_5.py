# badminton_gui_custom_limit.py
# 필요 패키지: matplotlib seaborn pandas
# ------------------------------------------
import random, math
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ────────────────────────────── 1) 한 번 시도해 스케줄 만들기
def _try_schedule(n, games_per, pair_limit, rng):
    players  = [f"P{i+1}" for i in range(n)]
    total_g  = n * games_per // 4
    remain   = {p: games_per for p in players}
    pair_cnt = defaultdict(lambda: defaultdict(int))
    sched    = []

    def ok(g):  # 한 그룹(4명)이 한도 초과 없나?
        return all(pair_cnt[a][b] < pair_limit for a,b in combinations(g,2))
    def score(g):
        return sum(pair_cnt[a][b] for a,b in combinations(g,2))

    while len(sched) < total_g:
        need = [p for p in players if remain[p] > 0]
        if len(need) < 4:
            need += sorted(players, key=lambda x: remain[x])[:4-len(need)]

        cand = list(combinations(need,4))
        rng.shuffle(cand)
        cand.sort(key=lambda g:(score(g), -sum(remain[p] for p in g)))
        grp  = next((g for g in cand if ok(g)), None)
        if grp is None:
            return None   # 이번 시드로 실패

        lst=list(grp); rng.shuffle(lst)
        sched.append((tuple(lst[:2]), tuple(lst[2:])))
        for a,b in combinations(grp,2):
            pair_cnt[a][b]+=1; pair_cnt[b][a]+=1
        for p in grp:
            remain[p]-=1
    return sched, pair_cnt

# ────────────────────────────── 2) 인원수 규칙 반영
def make_schedule(n, games_per=4, max_retry=3000):
    if n < 4 or n > 32:
        raise ValueError("인원 수는 4~32 명만 지원")

    # 4~7명 : 최대 3회, 8명 이상 : 최대 2회
    desired_limit = 3 if n <= 7 else 2

    # 2회가 가능한 경우(8명 이상) → 무조건 2회 스케줄 찾기
    if desired_limit == 2:
        rng = random.Random()
        for _ in range(max_retry):
            seed = rng.randrange(1<<30)
            res  = _try_schedule(n, games_per, 2, random.Random(seed))
            if res:
                schedule, pair_cnt = res
                break
        else:
            raise RuntimeError("최대 2회 조건을 만족하는 대진표를 찾지 못했어요.")
        used_limit = 2
    # 3회 허용(4~7명) → 한 번에 생성
    else:
        res = _try_schedule(n, games_per, 3, random.Random())
        if not res:
            raise RuntimeError("대진표 생성 실패")
        schedule, pair_cnt = res
        used_limit = 3

    # 슬롯 묶기
    max_parallel = max(1, n//4)
    slots, slot, used = [], [], set()
    for g in schedule:
        gset=set(g[0]+g[1])
        if (used & gset) or len(slot)>=max_parallel:
            slots.append(slot); slot, used = [], set()
        slot.append(g); used |= gset
    if slot: slots.append(slot)

    vals=[v for d in pair_cnt.values() for v in d.values()]
    stats={"max":max(vals),"avg":round(sum(vals)/len(vals),2),"limit":used_limit}
    players=[f"P{i+1}" for i in range(n)]
    return schedule, slots, stats, players

# ────────────────────────────── 3) 히트맵
def show_heatmap(schedule):
    if not schedule:
        messagebox.showinfo("알림","먼저 대진표를 생성하세요."); return
    pair=defaultdict(lambda:defaultdict(int))
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

# ────────────────────────────── 4) GUI 상태
schedule, slots, players = [], [], []
wait_list, playing = [], []
cur_slot=0

# ────────────────────────────── 5) GUI 콜백
def gen_btn():
    global schedule, slots, players, wait_list, playing, cur_slot
    try: n=int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류","숫자를 입력하세요."); return
    if n<4 or n>32:
        messagebox.showerror("입력 오류","4~32 명"); return

    try:
        schedule, slots, stats, players = make_schedule(n)
    except RuntimeError as e:
        messagebox.showerror("실패", str(e)); return

    text.delete("1.0",tk.END)
    for i,(t1,t2) in enumerate(schedule,1):
        text.insert(tk.END,f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")

    stat_lbl.config(text=f"max {stats['max']} / avg {stats['avg']} "
                         f"(허용 {stats['limit']})")
    wait_list[:] = players[:]; playing.clear(); cur_slot=0
    log.delete("1.0",tk.END)

def run_slot():
    global cur_slot
    if cur_slot>=len(slots):
        log.insert(tk.END,"🏁 완료\n"); return
    slot=slots[cur_slot]
    log.insert(tk.END,f"=== Slot {cur_slot+1} ===\n")
    batch=[]
    for t1,t2 in slot:
        g=list(t1+t2); batch+=g
        for p in g:
            if p in wait_list: wait_list.remove(p); playing.append(p)
        log.insert(tk.END,f"▶ {' & '.join(t1)} vs {' & '.join(t2)}\n")
    log.insert(tk.END,f"대기: {', '.join(wait_list) or '없음'}\n\n")
    log.see(tk.END)
    root.after(4000, lambda: finish_slot(batch))

def finish_slot(batch):
    global cur_slot
    for p in batch:
        if p in playing: playing.remove(p); wait_list.append(p)
    log.insert(tk.END,f"✔ 종료: {', '.join(batch)}\n\n")
    log.see(tk.END)
    cur_slot+=1
    root.after(600, run_slot)

def sim_btn():
    if not schedule:
        messagebox.showinfo("알림","먼저 대진표를 생성하세요."); return
    log.delete("1.0",tk.END)
    run_slot()

# ────────────────────────────── 6) Tk UI
root=tk.Tk(); root.title("4‑게임 배드민턴 스케줄러")

top=tk.Frame(root); top.pack(pady=10)
tk.Label(top,text="참가 인원 (4~32):").pack(side=tk.LEFT)
entry=tk.Entry(top,width=5); entry.pack(side=tk.LEFT)
tk.Button(top,text="대진표 생성",command=gen_btn)\
    .pack(side=tk.LEFT,padx=8)

tk.Button(root,text="히트맵 보기",command=lambda:show_heatmap(schedule))\
    .pack(pady=4)
tk.Button(root,text="시뮬레이션 시작",command=sim_btn).pack(pady=4)

text=tk.Text(root,height=15,width=60); text.pack(pady=6)
stat_lbl=tk.Label(root,text="중복 통계: -"); stat_lbl.pack()
tk.Label(root,text="시뮬레이션").pack()
log=tk.Text(root,height=15,width=60,fg="green"); log.pack(pady=4)

root.mainloop()

