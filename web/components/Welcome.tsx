"use client";

import { useEffect, useState } from "react";

const FULL_TEXT = "Hello handsome, welcome to Habbit. How would you like to be called?";
const PAUSE_POINTS = new Set([15, 34]);

type WelcomeProps = {
  onComplete: (name: string) => void;
};

export function Welcome({ onComplete }: WelcomeProps) {
  const [displayedText, setDisplayedText] = useState("");
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isTypingComplete, setIsTypingComplete] = useState(false);
  const [enteredName, setEnteredName] = useState("");
  const [cursorVisible, setCursorVisible] = useState(true);

  useEffect(() => {
    const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (prefersReducedMotion) {
      setDisplayedText(FULL_TEXT);
      setCurrentIndex(FULL_TEXT.length);
      setIsTypingComplete(true);
      return;
    }
    if (currentIndex >= FULL_TEXT.length) {
      setIsTypingComplete(true);
      return;
    }

    const delay = PAUSE_POINTS.has(currentIndex) ? 600 : 80;
    const timeout = window.setTimeout(() => {
      setDisplayedText((prev) => prev + FULL_TEXT[currentIndex]);
      setCurrentIndex((prev) => prev + 1);
    }, delay);

    return () => window.clearTimeout(timeout);
  }, [currentIndex]);

  useEffect(() => {
    if (!isTypingComplete || enteredName.length > 0) {
      return;
    }
    const interval = window.setInterval(() => {
      setCursorVisible((prev) => !prev);
    }, 800);
    return () => window.clearInterval(interval);
  }, [isTypingComplete, enteredName.length]);

  return (
    <main className="min-h-screen bg-background px-6 py-16">
      <div className="mx-auto flex max-w-md flex-col items-center justify-center gap-10 text-center">
        <div className="min-h-[120px] text-left text-2xl leading-relaxed text-text" aria-live="polite">
          {displayedText}
        </div>

        {isTypingComplete ? (
          <form
            className="flex w-full flex-col items-center gap-4"
            onSubmit={(event) => {
              event.preventDefault();
              const trimmedName = enteredName.trim();
              if (!trimmedName) {
                return;
              }
              onComplete(trimmedName);
            }}
          >
            <div className="relative w-full">
              <label htmlFor="welcome-name" className="sr-only">
                Your name
              </label>
              <input
                id="welcome-name"
                type="text"
                value={enteredName}
                onChange={(event) => setEnteredName(event.target.value)}
                placeholder="Your name"
                className="text-center"
                autoComplete="given-name"
              />
              {enteredName.length === 0 && cursorVisible ? (
                <span
                  className="pointer-events-none absolute left-1/2 top-1/2 h-6 w-[2px] -translate-x-1/2 -translate-y-1/2 bg-success"
                  aria-hidden="true"
                />
              ) : null}
            </div>
            <button
              type="submit"
              className="primary-button w-48"
              disabled={enteredName.trim().length === 0}
            >
              Continue
            </button>
          </form>
        ) : null}
      </div>
    </main>
  );
}
