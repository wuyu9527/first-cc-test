#!/usr/bin/env python3
"""番茄钟 — 桌面端番茄工作法计时器"""

import tkinter as tk
import winsound
import threading
import time


class PomodoroTimer:
    # 各阶段默认时长（秒）
    WORK_TIME = 25 * 60
    SHORT_BREAK = 5 * 60
    LONG_BREAK = 15 * 60
    SESSIONS_BEFORE_LONG_BREAK = 4

    MODE_DURATIONS = {
        "work": WORK_TIME,
        "short_break": SHORT_BREAK,
        "long_break": LONG_BREAK,
    }

    MODE_LABELS = {"work": "专注中", "short_break": "短休息", "long_break": "长休息"}
    MODE_TITLES = {"work": "专注", "short_break": "休息", "long_break": "长休"}

    COLORS = {
        "work":       ("#E74C3C", "#C0392B"),  # 红
        "short_break":("#2ECC71", "#27AE60"),  # 绿
        "long_break": ("#3498DB", "#2980B9"),  # 蓝
        "paused":     ("#95A5A6", "#7F8C8D"),  # 灰
        "bg":         "#1E1E1E",
        "surface":    "#2D2D2D",
        "text":       "#ECF0F1",
        "dim_text":   "#7F8C8D",
        "btn_text":   "#1E1E1E",
        "progress_bg":"#3D3D3D",
    }

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("番茄钟")
        self.root.geometry("380x520")
        self.root.resizable(False, False)
        self.root.configure(bg=self.COLORS["bg"])

        self.remaining = self.WORK_TIME
        self.total = self.WORK_TIME
        self.running = False
        self.mode = "work"
        self.mode_label_text = self.MODE_LABELS[self.mode]
        self.mode_title_text = self.MODE_TITLES[self.mode]
        self.completed_sessions = 0
        self.after_id = None
        self._progress_rect = None

        self._build_ui()
        self._update_display()

    # ── 界面构建 ──────────────────────────────────────────────────────

    def _build_ui(self):
        title_frame = tk.Frame(self.root, bg=self.COLORS["bg"])
        title_frame.pack(pady=(30, 10))

        self.mode_label = tk.Label(
            title_frame, text="专注中", font=("Microsoft YaHei", 14, "bold"),
            bg=self.COLORS["bg"], fg=self.COLORS["work"][0],
        )
        self.mode_label.pack()

        # 倒计时显示
        timer_frame = tk.Frame(self.root, bg=self.COLORS["surface"],
                               highlightthickness=0, bd=0)
        timer_frame.pack(pady=10)
        inner = tk.Frame(timer_frame, bg=self.COLORS["surface"], padx=50, pady=40)
        inner.pack()

        self.timer_label = tk.Label(
            inner, text="25:00", font=("Consolas", 56, "bold"),
            bg=self.COLORS["surface"], fg=self.COLORS["text"],
        )
        self.timer_label.pack()

        # 轮次圆点
        dots_frame = tk.Frame(self.root, bg=self.COLORS["bg"])
        dots_frame.pack(pady=(0, 10))
        self.dots = []
        for i in range(self.SESSIONS_BEFORE_LONG_BREAK):
            dot = tk.Label(dots_frame, text="●", font=("Segoe UI", 14),
                           bg=self.COLORS["bg"], fg=self.COLORS["progress_bg"])
            dot.pack(side=tk.LEFT, padx=4)
            self.dots.append(dot)

        # 进度条
        self.progress = tk.Canvas(
            self.root, width=300, height=4, bg=self.COLORS["bg"],
            highlightthickness=0,
        )
        self.progress.pack(pady=(0, 20))
        self._progress_rect = self.progress.create_rectangle(
            0, 0, 0, 4, fill=self.COLORS[self.mode][0], outline="",
        )

        # 按钮区域
        btn_frame = tk.Frame(self.root, bg=self.COLORS["bg"])
        btn_frame.pack(pady=5)

        btn_style = {
            "font": ("Microsoft YaHei", 11, "bold"),
            "relief": "flat",
            "bd": 0,
            "padx": 24,
            "pady": 8,
            "activebackground": self.COLORS["work"][1],
            "activeforeground": self.COLORS["text"],
        }

        self.start_btn = tk.Button(
            btn_frame, text="▶  开始", command=self._toggle_timer,
            bg=self.COLORS["work"][0], fg=self.COLORS["btn_text"], **btn_style,
        )
        self.start_btn.pack(side=tk.LEFT, padx=5)

        self.skip_btn = tk.Button(
            btn_frame, text="⏭  跳过", command=self._skip,
            bg=self.COLORS["dim_text"], fg=self.COLORS["btn_text"], **btn_style,
        )
        self.skip_btn.pack(side=tk.LEFT, padx=5)

        self.reset_btn = tk.Button(
            btn_frame, text="↺  重置", command=self._reset,
            bg=self.COLORS["dim_text"], fg=self.COLORS["btn_text"], **btn_style,
        )
        self.reset_btn.pack(side=tk.LEFT, padx=5)

        # 完成轮次统计
        self.session_label = tk.Label(
            self.root, text="已完成轮次: 0",
            font=("Microsoft YaHei", 10), bg=self.COLORS["bg"], fg=self.COLORS["dim_text"],
        )
        self.session_label.pack(pady=(15, 5))

        # 窗口置顶开关
        self.ontop_var = tk.BooleanVar(value=True)
        self.root.attributes("-topmost", True)
        top_cb = tk.Checkbutton(
            self.root, text="窗口置顶", variable=self.ontop_var,
            command=self._toggle_ontop,
            font=("Microsoft YaHei", 9), bg=self.COLORS["bg"], fg=self.COLORS["dim_text"],
            selectcolor=self.COLORS["surface"],
            activebackground=self.COLORS["bg"],
            activeforeground=self.COLORS["text"],
        )
        top_cb.pack(pady=(0, 10))

        # 快捷键绑定
        self.root.bind("<space>", lambda e: self._toggle_timer())
        self.root.bind("<r>", lambda e: self._reset())
        self.root.bind("<Right>", lambda e: self._skip())
        self.root.bind("<Escape>", lambda e: self.root.destroy())

    # ── 显示更新 ──────────────────────────────────────────────────────

    def _update_display(self, minutes=None, seconds=None):
        """刷新倒计时、阶段标签、圆点、进度条。"""
        if minutes is None:
            minutes, seconds = divmod(self.remaining, 60)
        self.timer_label.config(text=f"{minutes:02d}:{seconds:02d}")

        color = self.COLORS[self.mode][0] if self.running else self.COLORS["paused"][0]
        self.mode_label.config(text=self.mode_label_text, fg=color)

        # 轮次圆点
        for i, dot in enumerate(self.dots):
            dot.config(fg=self.COLORS[self.mode][0] if i < self.completed_sessions else self.COLORS["progress_bg"])

        # 进度条
        ratio = self.remaining / self.total if self.total > 0 else 0
        bar_width = int(300 * (1 - ratio))
        self.progress.itemconfig(self._progress_rect, width=bar_width,
                                 fill=self.COLORS[self.mode][0])

        self.session_label.config(text=f"已完成轮次: {self.completed_sessions}")

        btn_text = "⏸  暂停" if self.running else "▶  开始"
        self.start_btn.config(
            text=btn_text,
            bg=self.COLORS["paused"][0] if self.running else self.COLORS[self.mode][0],
        )

    # ── 计时逻辑 ──────────────────────────────────────────────────────

    def _tick(self):
        """每秒执行一次，驱动倒计时。"""
        if not self.running:
            return

        if self.remaining > 0:
            self.remaining -= 1
            mins, secs = divmod(self.remaining, 60)
            self._update_display(minutes=mins, seconds=secs)
            self.root.title(f"{self.mode_title_text} {mins:02d}:{secs:02d} — 番茄钟")
            self.after_id = self.root.after(1000, self._tick)
        else:
            self._on_timer_end()

    def _on_timer_end(self):
        """倒计时归零时触发。"""
        self.running = False
        self._play_notification()
        self._switch_mode()
        self._update_display()
        self.root.title("番茄钟 — 时间到！")
        was_ontop = self.ontop_var.get()
        self.root.attributes("-topmost", True)
        self.root.deiconify()
        self.root.lift()
        if not was_ontop:
            self.root.attributes("-topmost", False)

    def _switch_mode(self):
        """根据已完成的轮次切换到下一阶段。"""
        if self.mode == "work":
            self.completed_sessions += 1
            if self.completed_sessions % self.SESSIONS_BEFORE_LONG_BREAK == 0:
                self.mode = "long_break"
            else:
                self.mode = "short_break"
        else:
            self.mode = "work"

        self.remaining = self.MODE_DURATIONS[self.mode]
        self.total = self.remaining
        self.mode_label_text = self.MODE_LABELS[self.mode]
        self.mode_title_text = self.MODE_TITLES[self.mode]

    def _toggle_timer(self):
        """开始 / 暂停切换。"""
        if self.running:
            self.running = False
            if self.after_id:
                self.root.after_cancel(self.after_id)
                self.after_id = None
        else:
            self.running = True
            self.after_id = self.root.after(1000, self._tick)
        self._update_display()

    def _pause_do_resume(self, action):
        """暂停 → 执行 action → 恢复（若之前正在运行）的通用模板。"""
        was_running = self.running
        self.running = False
        if self.after_id:
            self.root.after_cancel(self.after_id)
            self.after_id = None
        action()
        if was_running:
            self.running = True
            self.after_id = self.root.after(1000, self._tick)
        self._update_display()

    def _reset(self):
        """将当前阶段倒计时重置为初始时长。"""
        def do_reset():
            self.remaining = self.total
        self._pause_do_resume(do_reset)

    # ── 通知 ────────────────────────────────────────────────────────

    def _play_notification(self):
        """后台线程播放三声系统提示音。"""
        def beep():
            for _ in range(3):
                winsound.MessageBeep(winsound.MB_ICONEXCLAMATION)
                time.sleep(0.3)
        threading.Thread(target=beep, daemon=True).start()

    # ── 窗口选项 ────────────────────────────────────────────────────

    def _toggle_ontop(self):
        self.root.attributes("-topmost", self.ontop_var.get())

    # ── 跳过 ────────────────────────────────────────────────────────

    def _skip(self):
        """跳过当前阶段，立即进入下一阶段。"""
        self._pause_do_resume(self._switch_mode)

    # ── 启动 ────────────────────────────────────────────────────────

    def run(self):
        # 窗口居中
        self.root.update_idletasks()
        w, h = self.root.winfo_width(), self.root.winfo_height()
        sw = self.root.winfo_screenwidth()
        sh = self.root.winfo_screenheight()
        x = (sw - w) // 2
        y = (sh - h) // 2 - 30
        self.root.geometry(f"+{x}+{y}")
        self.root.mainloop()


if __name__ == "__main__":
    PomodoroTimer().run()
