# HarvestHub - Project Context & Guidelines

## 1. UI Theme & Global Design System
- **Global Consistency:** The UI must follow a strict global design system. All modules (Customer, Farmer, Administrator) must share the same core components, color palette, and typography to ensure 100% consistency across the entire application.
- **Theme:** "eGreen Basket" - Modern, clean, and agriculture-focused.
- **Components:** Buttons, text fields, cards, dialogs, and navigation elements must be defined globally and reused. Hardcoding styles in individual screens is strictly prohibited.

## 2. Coding Standards & Human-Written Style
- **Variable & Function Naming:** Use clear, descriptive, and context-appropriate variable and function names (e.g., `fetchCustomerOrders()` instead of `getData()`). The code must look and read logically, exactly like an experienced human developer would write it.
- **No Unnecessary Comments:** Avoid stating the obvious. Code should be self-documenting through good naming conventions. Only use comments to explain complex business logic.
- **No Emojis:** Do not use emojis anywhere in the codebase (no emojis in comments, console logs, or UI text) unless explicitly required by a core feature.
- **Clean Architecture:** Maintain a clean separation between the UI layer, application logic, and database layer.

## 3. General Rules
- Ensure smooth transitions and fast load times.
- Strictly adhere to the requirements specified in the SRS.
