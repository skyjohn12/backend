import { useState, useCallback } from "react";

/**
 * Custom Hook - useToggle
 * Demonstrates: Simple custom hook pattern, boolean state management
 *
 * A reusable hook for managing boolean toggle state (modals, dropdowns, etc.)
 */
export function useToggle(
  initialValue = false
): [boolean, () => void, () => void, () => void] {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => {
    setValue((prev) => !prev);
  }, []);

  const setTrue = useCallback(() => {
    setValue(true);
  }, []);

  const setFalse = useCallback(() => {
    setValue(false);
  }, []);

  return [value, toggle, setTrue, setFalse];
}

/**
 * Usage Example:
 *
 * const [isOpen, toggle, open, close] = useToggle(false);
 *
 * <Button onClick={open}>Open Modal</Button>
 * <Modal isOpen={isOpen} onClose={close}>...</Modal>
 */
