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
    <div className="min-h-screen bg-background px-6 py-16">
      <div className="mx-auto flex max-w-md flex-col items-center justify-center gap-10 text-center">
        <div className="min-h-[120px] text-left text-2xl leading-relaxed text-text">
          {displayedText}
        </div>

        {isTypingComplete ? (
          <div className="flex w-full flex-col items-center gap-4">
            <div className="relative w-full">
              <input
                type="text"
                value={enteredName}
                onChange={(event) => setEnteredName(event.target.value)}
                placeholder="Your name"
                className="text-center"
              />
              {enteredName.length === 0 && cursorVisible ? (
                <span className="pointer-events-none absolute left-1/2 top-1/2 h-6 w-[2px] -translate-x-1/2 -translate-y-1/2 bg-success" />
              ) : null}
            </div>
            <button
              className="primary-button w-48"
              onClick={() => onComplete(enteredName.trim())}
              disabled={enteredName.trim().length === 0}
            >
              Continue
            </button>
          </div>
        ) : null}
      </div>
    </div>
  );
}
