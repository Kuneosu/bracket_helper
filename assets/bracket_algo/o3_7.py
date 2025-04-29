# badminton_gui_strict_concurrent.py  (Python ≥3.10)
# pip install matplotlib seaborn pandas
# ─────────────────────────────────────────────────────────
import random, math
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd, matplotlib.pyplot as plt, seaborn as sns

GPP = 4   # games per player

def limit_of(n:int)->int:       # 인원수별 기본 중복 한도
    return 4 if n==4 else 3 if n<=7 else 2

# ────────────────── 1) 슬롯‑우선 스케줄 한 번 생성
def _build_once(n:int, limit:int, rng:random.Random):
    players=[f"P{i+1}" for i in range(n)]
    remain={p:GPP for p in players}
    pair=defaultdict(lambda:defaultdict(int))
    schedule=[]; slots=[]
    max_par=n//4

    while any(remain[p]>0 for p in players):
        used=set(); slot=[]
        while len(slot)<max_par:
            cands=[p for p in players if remain[p]>0 and p not in used]
            if len(cands)<4: break          # 더 채울 수 없음
            best=None; best_key=None
            rng.shuffle(cands)
            for g in combinations(cands,4):
                if any(pair[a][b]>=limit for a,b in combinations(g,2)):
                    continue
                overlap=sum(pair[a][b] for a,b in combinations(g,2))
                needs=-sum(remain[p] for p in g)   # 남은 경기 많은 쪽 우선
                key=(overlap,needs)
                if best_key is None or key<best_key:
                    best,best_key=g,key
            if best is None: break          # 이번 슬롯 더 못 채움
            lst=list(best); rng.shuffle(lst)
            slot.append((tuple(lst[:2]),tuple(lst[2:])))
            used|=set(best)
            for p in best: remain[p]-=1
            for a,b in combinations(best,2):
                pair[a][b]+=1; pair[b][a]+=1

        # ── 동시 출전 보장 검사 ──
        remain_games=sum(remain.values())
        games_left=remain_games//4
        must_fill=max_par if games_left>=max_par else games_left
        if len(slot)<must_fill:           # 규정만큼 못 채웠으면 실패
            return None

        slots.append(slot); schedule.extend(slot)

    vals=[v for d in pair.values() for v in d.values()]
    stats={"max":max(vals),"avg":round(sum(vals)/len(vals),2),"limit":limit}
    return schedule,slots,stats,players

# ────────────────── 2) 완전 스케줄 찾기(재시도 + 한도 완화)
def generate_schedule(n:int,maxRetry:int=3000):
    if not 4<=n<=32: raise ValueError("인원 4‑32")
    base=limit_of(n); rng=random.Random()
    # 첫 단계: base 한도로 시도
    for _ in range(maxRetry):
        seed=rng.randrange(1<<30)
        res=_build_once(n,base,random.Random(seed))
        if res: return res
    # 두 번째 단계: 한도 +1 로 완화 후 한 번만 시도
    if base<3:
        res=_build_once(n,base+1,random.Random())
        if res: return res
    raise RuntimeError("조건에 맞는 대진표를 찾지 못했습니다.")

# ────────────────── 3) 히트맵
def heatmap(schedule):
    if not schedule: messagebox.showinfo("알림","먼저 대진표를 생성");return
    pc=defaultdict(lambda:defaultdict(int)); ps=set()
    for t1,t2 in schedule:
        g=list(t1+t2); ps|=set(g)
        for a,b in combinations(g,2): pc[a][b]+=1; pc[b][a]+=1
    ps=sorted(ps); df=pd.DataFrame(0,index=ps,columns=ps)
    for a in ps:
        for b in ps:
            if a!=b: df.loc[a,b]=pc[a][b]
    plt.figure(figsize=(8,6))
    sns.heatmap(df,annot=True,cmap="YlGnBu",fmt="d",cbar=True)
    plt.tight_layout(); plt.show()

# ────────────────── 4) GUI 상태
schedule,slots,players=[],[],[]
wait,playing,cur= [],[],0

# ────────────────── 5) GUI 콜백
def build():
    global schedule,slots,players,wait,playing,cur
    try: n=int(ent.get())
    except: messagebox.showerror("입력오류","숫자"); return
    if not 4<=n<=32: messagebox.showerror("입력오류","4‑32"); return
    try: schedule,slots,stats,players=generate_schedule(n)
    except RuntimeError as e: messagebox.showerror("실패",str(e)); return
    out.delete("1.0",tk.END)
    for i,(t1,t2) in enumerate(schedule,1):
        out.insert(tk.END,f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")
    lbl.config(text=f"max {stats['max']} / avg {stats['avg']} (허용 {stats['limit']})")
    wait[:]=players[:]; playing.clear(); cur=0; log.delete("1.0",tk.END)

def play_slot():
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
    cur+=1; play_slot()

def start_sim():
    if not schedule: messagebox.showinfo("알림","대진표 먼저"); return
    log.delete("1.0",tk.END); play_slot()

# ────────────────── 6) Tk UI
root=tk.Tk(); root.title("배드민턴 4‑게임 스케줄러")

top=tk.Frame(root); top.pack(pady=10)
tk.Label(top,text="참가 인원 (4‑32):").pack(side=tk.LEFT)
ent=tk.Entry(top,width=5); ent.pack(side=tk.LEFT)
tk.Button(top,text="대진표 생성",command=build).pack(side=tk.LEFT,padx=8)

tk.Button(root,text="히트맵 보기",command=lambda:heatmap(schedule)).pack(pady=4)
tk.Button(root,text="시뮬레이션 시작",command=start_sim).pack(pady=4)

out=tk.Text(root,height=15,width=60); out.pack(pady=6)
lbl=tk.Label(root,text="중복 통계 -"); lbl.pack()
tk.Label(root,text="시뮬레이션").pack()
log=tk.Text(root,height=15,width=60,fg="green"); log.pack(pady=4)

root.mainloop()

