# ── pip install matplotlib seaborn pandas ─────────────────────────
import random, math
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
# ───────────────────────────────────────────────────────────────────
GAMES_PER_PLAYER = 4                 # 1인당 반드시 4경기

def limit_of(n: int) -> int:
    """인원수별 최대 중복 허용"""
    return 4 if n == 4 else 3 if n <= 7 else 2

# ───────────────────────────────────────────────────────────────────
# 1. 슬롯‑우선 스케줄을 *한 번* 만들어 본다
def _build_once(n: int, pair_limit: int, rng: random.Random):
    max_parallel = max(1, n // 4)
    players      = [f"P{i+1}" for i in range(n)]
    remain       = {p: GAMES_PER_PLAYER for p in players}
    pair_cnt     = defaultdict(lambda: defaultdict(int))
    schedule, slots = [], []

    while any(remain[p] > 0 for p in players):
        used, slot = set(), []

        # 슬롯 안에서 최대한 채운다
        while len(slot) < max_parallel:
            cands = [p for p in players if remain[p] > 0 and p not in used]
            if len(cands) < 4:
                break

            # 후보 4명 조합 중 “중복 점수 + 잔여 경기” 기준 최적
            best, best_key = None, None
            rng.shuffle(cands)
            for g in combinations(cands, 4):
                if any(pair_cnt[a][b] >= pair_limit
                       for a, b in combinations(g, 2)):
                    continue
                overlap = sum(pair_cnt[a][b] for a, b in combinations(g, 2))
                needsum = -sum(remain[p] for p in g)          # 많을수록 우선
                key     = (overlap, needsum)
                if best_key is None or key < best_key:
                    best, best_key = g, key
            if best is None:
                break

            # 팀 2 : 2 분배
            lst = list(best); rng.shuffle(lst)
            slot.append((tuple(lst[:2]), tuple(lst[2:])))
            used.update(best)

            # 상태 업데이트
            for a, b in combinations(best, 2):
                pair_cnt[a][b] += 1; pair_cnt[b][a] += 1
            for p in best:
                remain[p] -= 1

        if not slot:           # 한 팀도 못 넣었다 → 실패
            return None

        slots.append(slot)
        schedule.extend(slot)

    # 통계
    vals = [v for d in pair_cnt.values() for v in d.values()]
    stats = {
        "max": max(vals),
        "avg": round(sum(vals) / len(vals), 2),
        "limit": pair_limit,
    }
    return schedule, slots, stats, players

# ───────────────────────────────────────────────────────────────────
# 2. 인원‑규칙을 적용해 “완전한” 스케줄 찾기
def generate_schedule(n: int, max_retry: int = 3000):
    if n < 4 or n > 32:
        raise ValueError("인원은 4‑32 명")

    target_limit = limit_of(n)
    rng_outer    = random.Random()

    # 8명 이상 & limit=2 는 random‑restart
    retries = max_retry if target_limit == 2 else 1

    for _ in range(retries):
        seed = rng_outer.randrange(1 << 30)
        res  = _build_once(n, target_limit, random.Random(seed))
        if res:
            schedule, slots, stats, players = res
            # (8명 이상) 必 최대 2회 만족하면 성공
            if stats['max'] <= target_limit:
                return schedule, slots, stats, players
    raise RuntimeError(
        f"조건을 만족하는 대진표(최대 {target_limit}회 중복)를 찾지 못했습니다."
    )

# ───────────────────────────────────────────────────────────────────
# 3. 히트맵
def heatmap(schedule):
    if not schedule:
        messagebox.showinfo("알림", "먼저 대진표를 생성하세요."); return
    pair = defaultdict(lambda: defaultdict(int)); ps = set()
    for t1,t2 in schedule:
        g = list(t1+t2); ps.update(g)
        for a, b in combinations(g, 2):
            pair[a][b] += 1; pair[b][a] += 1
    ps = sorted(ps)
    df = pd.DataFrame(0, index=ps, columns=ps)
    for a in ps:
        for b in ps:
            if a != b: df.loc[a, b] = pair[a][b]
    plt.figure(figsize=(8, 6))
    sns.heatmap(df, annot=True, cmap="YlGnBu", fmt="d", cbar=True)
    plt.title("플레이어 간 중복 히트맵"); plt.tight_layout(); plt.show()

# ───────────────────────────────────────────────────────────────────
# 4. GUI 상태
schedule = []; slots = []; players=[]
wait, playing, cur_slot = [], [], 0

# ───────────────────────────────────────────────────────────────────
# 5. GUI 콜백
def make_schedule():
    global schedule, slots, players, wait, playing, cur_slot
    try: n = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력하세요."); return
    if n < 4 or n > 32:
        messagebox.showerror("입력 오류", "4‑32 명만"); return

    try:
        schedule, slots, stats, players = generate_schedule(n)
    except RuntimeError as e:
        messagebox.showerror("실패", str(e)); return

    txt.delete("1.0", tk.END)
    for i, (t1, t2) in enumerate(schedule, 1):
        txt.insert(tk.END, f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")

    info.config(text=f"max {stats['max']} / avg {stats['avg']} "
                     f"(허용 {stats['limit']})")
    wait[:] = players[:]; playing.clear(); cur_slot = 0
    log.delete("1.0", tk.END)

def run_slot():
    global cur_slot
    if cur_slot >= len(slots):
        log.insert(tk.END, "🏁 경기 종료\n"); return
    slot = slots[cur_slot]
    used=[]
    log.insert(tk.END, f"=== Slot {cur_slot+1} ===\n")
    for t1, t2 in slot:
        g = list(t1+t2); used += g
        for p in g:
            if p in wait: wait.remove(p); playing.append(p)
        log.insert(tk.END, f"▶ {' & '.join(t1)}  vs  {' & '.join(t2)}\n")
    log.insert(tk.END, f"대기: {', '.join(wait) or '없음'}\n\n")
    log.see(tk.END)
    root.after(4000, lambda: finish_slot(used))

def finish_slot(used):
    global cur_slot
    for p in used:
        if p in playing: playing.remove(p); wait.append(p)
    cur_slot += 1
    run_slot()

def sim_start():
    if not schedule:
        messagebox.showinfo("알림", "먼저 대진표를 생성하세요."); return
    log.delete("1.0", tk.END); run_slot()

# ───────────────────────────────────────────────────────────────────
# 6. Tkinter UI
root = tk.Tk(); root.title("배드민턴 4‑게임 스케줄러")

top = tk.Frame(root); top.pack(pady=10)
tk.Label(top, text="참가 인원 (4‑32):").pack(side=tk.LEFT)
entry = tk.Entry(top, width=5); entry.pack(side=tk.LEFT)
tk.Button(top, text="대진표 생성", command=make_schedule)\
    .pack(side=tk.LEFT, padx=8)

tk.Button(root, text="히트맵 보기",
          command=lambda: heatmap(schedule)).pack(pady=4)
tk.Button(root, text="시뮬레이션 시작", command=sim_start).pack(pady=4)

txt = tk.Text(root, height=15, width=60); txt.pack(pady=6)
info = tk.Label(root, text="중복 통계 -"); info.pack()

tk.Label(root, text="시뮬레이션").pack()
log = tk.Text(root, height=15, width=60, fg="green"); log.pack(pady=4)

root.mainloop()

