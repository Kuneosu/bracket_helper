# badminton_gui_final.py
# ───────────────────────────────────────────────────────────
import random, math
from itertools import combinations
from collections import defaultdict
import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

GPP = 4                                 # 1인당 경기 수

def pair_limit_by_n(n: int) -> int:     # 인원수별 기본 중복 허용
    return 4 if n == 4 else 3 if n <= 7 else 2

# ───────────────────────────────────────────────────────────
# 1)  한 번의 시드(seed)로 스케줄을 생성
def _build_once(n: int, pair_limit: int, rng: random.Random):
    players      = [f"P{i+1}" for i in range(n)]
    remain_games = {p: GPP for p in players}
    pair_cnt     = defaultdict(lambda: defaultdict(int))
    schedule     = []
    slots        = []

    max_parallel = n // 4                         # 슬롯당 경기 수

    while any(remain_games[p] > 0 for p in players):
        slot, used = [], set()

        # 슬롯 안에서 max_parallel 만큼 채운다
        while len(slot) < max_parallel:
            needers = [p for p in players if remain_games[p] > 0 and p not in used]
            if len(needers) < 4:
                break                             # 더 이상 그룹 불가

            # 4명 조합 탐색
            best, best_key = None, None
            rng.shuffle(needers)
            for g in combinations(needers, 4):
                if any(pair_cnt[a][b] >= pair_limit for a, b in combinations(g, 2)):
                    continue
                overlap = sum(pair_cnt[a][b] for a, b in combinations(g, 2))
                remain_sum = -sum(remain_games[p] for p in g)  # 더 많이 남은 선수를 우선
                key = (overlap, remain_sum)
                if best_key is None or key < best_key:
                    best, best_key = g, key

            if best is None:
                break                             # 슬롯 더 못 채움

            # 2:2 팀 랜덤 분배
            tmp = list(best)
            rng.shuffle(tmp)
            slot.append((tuple(tmp[:2]), tuple(tmp[2:])))
            used.update(best)

            # 상태 갱신
            for a, b in combinations(best, 2):
                pair_cnt[a][b] += 1
                pair_cnt[b][a] += 1
            for p in best:
                remain_games[p] -= 1

        # ── 슬롯 충족성 검사 ───────────────────────────────
        games_left = sum(remain_games.values()) // 4
        need_now   = max_parallel if games_left >= max_parallel else games_left
        if len(slot) < need_now and games_left > 0:      # 마지막 슬롯이 아님
            return None                                  # 이 시드 실패

        slots.append(slot)
        schedule.extend(slot)

    # 통계
    overlaps = [v for d in pair_cnt.values() for v in d.values()]
    stats = {
        "max":  max(overlaps),
        "avg":  round(sum(overlaps) / len(overlaps), 2),
        "limit": pair_limit
    }
    return schedule, slots, stats, players

# ───────────────────────────────────────────────────────────
# 2)  ‘재시도 + 한도 완화’ 로 완전 스케줄 찾기
def generate_schedule(n: int, restart_base: int = 3000):
    if n < 4 or n > 32:
        raise ValueError("인원 수는 4‑32 명만 지원합니다.")

    base_limit = pair_limit_by_n(n)
    rng_outer  = random.Random()
    restarts   = restart_base + int((n - 8) * 200) if n > 8 else restart_base

    # (A) base_limit 으로 재시도
    for _ in range(restarts):
        res = _build_once(n, base_limit, random.Random(rng_outer.randrange(1 << 30)))
        if res:
            return res

    # (B) 8명↑ & base_limit==2 -> 한도 3으로 완화
    if base_limit == 2:
        for _ in range(restarts):
            res = _build_once(n, 3, random.Random(rng_outer.randrange(1 << 30)))
            if res:
                return res

    raise RuntimeError(
        f"{n}명으로 주어진 조건(중복·동시출전)을 {restarts}회 재시도했으나 "
        f"충족하는 대진표를 얻지 못했습니다.\n"
        "- 재시도 횟수를 늘리거나\n"
        "- 중복 허용 한도를 높여 보세요."
    )

# ───────────────────────────────────────────────────────────
# 3)  히트맵
def show_heatmap(schedule):
    if not schedule:
        messagebox.showinfo("알림", "먼저 대진표를 생성하세요."); return
    pair = defaultdict(lambda: defaultdict(int)); ps = set()
    for t1, t2 in schedule:
        g = list(t1 + t2); ps |= set(g)
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

# ───────────────────────────────────────────────────────────
# 4)  GUI 상태
schedule, slots, players = [], [], []
wait_list, playing_list = [], []
cur_slot = 0

# ───────────────────────────────────────────────────────────
# 5)  GUI 콜백
def create_schedule():
    global schedule, slots, players, wait_list, playing_list, cur_slot
    try:
        n = int(entry.get())
    except ValueError:
        messagebox.showerror("입력 오류", "숫자를 입력하세요."); return
    if not (4 <= n <= 32):
        messagebox.showerror("입력 오류", "4‑32 명만 가능합니다."); return
    try:
        schedule, slots, stats, players = generate_schedule(n)
    except RuntimeError as e:
        messagebox.showerror("실패", str(e)); return

    text.delete("1.0", tk.END)
    for i, (t1, t2) in enumerate(schedule, 1):
        text.insert(tk.END, f"{i:2}: {', '.join(t1)} vs {', '.join(t2)}\n")

    stat_lbl.config(text=f"max {stats['max']} / avg {stats['avg']} "
                         f"(허용 {stats['limit']})")
    wait_list[:] = players[:]; playing_list.clear(); cur_slot = 0
    log.delete("1.0", tk.END)

def run_slot():
    global cur_slot
    if cur_slot >= len(slots):
        log.insert(tk.END, "🏁 경기 종료\n"); return
    slot = slots[cur_slot]; used = []
    log.insert(tk.END, f"=== Slot {cur_slot + 1} ===\n")
    for t1, t2 in slot:
        g = list(t1 + t2); used += g
        for p in g:
            if p in wait_list: wait_list.remove(p); playing_list.append(p)
        log.insert(tk.END, f"▶ {' & '.join(t1)}  vs  {' & '.join(t2)}\n")
    log.insert(tk.END, f"대기: {', '.join(wait_list) or '없음'}\n\n")
    log.see(tk.END)
    root.after(4000, lambda: finish_slot(used))

def finish_slot(used):
    global cur_slot
    for p in used:
        if p in playing_list:
            playing_list.remove(p); wait_list.append(p)
    cur_slot += 1
    run_slot()

def start_sim():
    if not schedule:
        messagebox.showinfo("알림", "먼저 대진표를 생성하세요."); return
    log.delete("1.0", tk.END); run_slot()

# ───────────────────────────────────────────────────────────
# 6)  Tk 인터페이스
root = tk.Tk(); root.title("배드민턴 4‑게임 스케줄러")

top = tk.Frame(root); top.pack(pady=10)
tk.Label(top, text="참가 인원 (4‑32):").pack(side=tk.LEFT)
entry = tk.Entry(top, width=5); entry.pack(side=tk.LEFT)
tk.Button(top, text="대진표 생성", command=create_schedule)\
    .pack(side=tk.LEFT, padx=8)

tk.Button(root, text="히트맵 보기",
          command=lambda: show_heatmap(schedule)).pack(pady=4)
tk.Button(root, text="시뮬레이션 시작", command=start_sim).pack(pady=4)

text = tk.Text(root, height=15, width=60); text.pack(pady=6)
stat_lbl = tk.Label(root, text="중복 통계 -"); stat_lbl.pack()

tk.Label(root, text="시뮬레이션").pack()
log = tk.Text(root, height=15, width=60, fg="green"); log.pack(pady=4)

root.mainloop()
