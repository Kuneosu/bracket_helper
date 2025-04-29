# badminton_gui_court_param.py
# pip install matplotlib seaborn pandas
import random
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd, matplotlib.pyplot as plt, seaborn as sns

GPP = 4  # games per player

def limit_by_n(n):            # 기본 중복 한도
    return 4 if n == 4 else 3 if n <= 7 else 2

# ────────────────────────────────────────────────
def _build_once(n, courts, limit, rng):
    """주어진 ‘코트 수(courts)’ 로 한 번 스케줄 생성. 실패 시 None"""
    pl = [f"P{i+1}" for i in range(n)]
    remain = {p: GPP for p in pl}
    pair   = defaultdict(lambda: defaultdict(int))
    schedule, slots = [], []

    while any(remain[p] > 0 for p in pl):
        used, slot = set(), []
        while len(slot) < courts:
            cand = [p for p in pl if remain[p] > 0 and p not in used]
            if len(cand) < 4: break

            best, best_key = None, None
            rng.shuffle(cand)
            for g in combinations(cand, 4):
                if any(pair[a][b] >= limit for a, b in combinations(g, 2)):
                    continue
                overlap = sum(pair[a][b] for a, b in combinations(g, 2))
                need    = -sum(remain[p] for p in g)
                key     = (overlap, need)
                if best_key is None or key < best_key:
                    best, best_key = g, key
            if best is None: break

            lst=list(best); rng.shuffle(lst)
            slot.append((tuple(lst[:2]), tuple(lst[2:])))
            used |= set(best)
            for a, b in combinations(best, 2):
                pair[a][b] += 1; pair[b][a] += 1
            for p in best: remain[p] -= 1

        # 슬롯이 채워져야 하는 최소 경기 수 = min(courts, 남은_경기/4)
        need_games = min(courts, sum(remain.values()) // 4)
        if len(slot) < need_games:          # 못 채움 → 실패
            return None

        slots.append(slot); schedule += slot

    vals=[v for d in pair.values() for v in d.values()]
    stats={"max":max(vals),"avg":round(sum(vals)/len(vals),2),"limit":limit}
    return schedule, slots, stats, pl

def generate_schedule(n, courts, restart=3000):
    if not 4 <= n <= 32:     raise ValueError("인원 4‑32")
    if not 1 <= courts <= n//4: raise ValueError("코트 수는 1‑⌊N/4⌋")

    base = limit_by_n(n)
    rng  = random.Random()

    # ① 기본 한도로 재시도
    for _ in range(restart):
        res=_build_once(n,courts,base,random.Random(rng.randrange(1<<30)))
        if res: return res

    # ② 8명↑ & 2회 한도 실패 → 3회로 완화
    if base==2:
        for _ in range(restart):
            res=_build_once(n,courts,3,random.Random(rng.randrange(1<<30)))
            if res: return res
    raise RuntimeError("조건을 만족하는 대진표를 찾지 못했습니다.")

# ────────────────────────────────────────────────
def heatmap(sched):
    if not sched: messagebox.showinfo("알림","대진표 먼저"); return
    pc=defaultdict(lambda:defaultdict(int)); ps=set()
    for t1,t2 in sched:
        g=list(t1+t2); ps|=set(g)
        for a,b in combinations(g,2): pc[a][b]+=1; pc[b][a]+=1
    ps=sorted(ps); df=pd.DataFrame(0,index=ps,columns=ps)
    for a in ps:
        for b in ps:
            if a!=b: df.loc[a,b]=pc[a][b]
    plt.figure(figsize=(8,6))
    sns.heatmap(df,annot=True,cmap="YlGnBu",fmt="d",cbar=True)
    plt.tight_layout(); plt.show()

# ────────────────────────────────────────────────
# GUI 상태
schedule, slots, players=[],[],[]
wait, playing, cur = [],[],0

# ────────────────────────────────────────────────
def build():
    global schedule,slots,players,wait,playing,cur
    try:
        n=int(entry_n.get()); c=int(entry_c.get())
    except: messagebox.showerror("입력 오류","숫자"); return
    try:
        schedule,slots,stats,players=generate_schedule(n,c)
    except Exception as e:
        messagebox.showerror("실패",str(e)); return

    text.delete("1.0",tk.END)
    for i,(t1,t2) in enumerate(schedule,1):
        text.insert(tk.END,f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")
    lbl.config(text=f"max {stats['max']} / avg {stats['avg']} (허용 {stats['limit']})")
    wait[:]=players[:]; playing.clear(); cur=0; log.delete("1.0",tk.END)

def run_slot():
    global cur
    if cur>=len(slots):
        log.insert(tk.END,"🏁 끝\n"); return
    slot=slots[cur]; used=[]
    log.insert(tk.END,f"=== Slot {cur+1} ===\n")
    for t1,t2 in slot:
        g=list(t1+t2); used+=g
        for p in g:
            if p in wait: wait.remove(p); playing.append(p)
        log.insert(tk.END,f"▶ {' & '.join(t1)} vs {' & '.join(t2)}\n")
    log.insert(tk.END,f"대기: {', '.join(wait) or '없음'}\n\n")
    log.see(tk.END)
    root.after(4000,lambda: finish(used))

def finish(used):
    global cur
    for p in used:
        if p in playing: playing.remove(p); wait.append(p)
    cur+=1; run_slot()

def sim():
    if not schedule: messagebox.showinfo("알림","대진표 먼저"); return
    log.delete("1.0",tk.END); run_slot()

# ────────────────────────────────────────────────
root=tk.Tk(); root.title("배드민턴 스케줄러 (코트 지정)")

frm=tk.Frame(root); frm.pack(pady=10)
tk.Label(frm,text="인원(4‑32):").grid(row=0,column=0)
entry_n=tk.Entry(frm,width=4); entry_n.grid(row=0,column=1)
tk.Label(frm,text="코트 수:").grid(row=0,column=2)
entry_c=tk.Entry(frm,width=4); entry_c.grid(row=0,column=3)
tk.Button(frm,text="대진표 생성",command=build)\
    .grid(row=0,column=4,padx=8)

tk.Button(root,text="히트맵",command=lambda:heatmap(schedule)).pack(pady=4)
tk.Button(root,text="시뮬레이션",command=sim).pack(pady=4)

text=tk.Text(root,height=15,width=60); text.pack(pady=6)
lbl=tk.Label(root,text="중복 통계 -"); lbl.pack()
tk.Label(root,text="시뮬레이션").pack()
log=tk.Text(root,height=15,width=60,fg="green"); log.pack(pady=4)

root.mainloop()
