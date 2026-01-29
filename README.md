# Mastermind Game – FPGA Implementation (Verilog)

## Project Overview
This project is a hardware-based implementation of the classic Mastermind game designed using Verilog HDL and deployed on an FPGA board. 
The game logic, user input handling, feedback generation, and display control are all implemented entirely in hardware without the use of a soft processor.
The project focuses on finite state machines, modular digital design, and synchronous logic.

## Game Description
Mastermind is a code-breaking game in which the system stores a secret code and the player attempts to guess it within a limited number of attempts.
After each guess, feedback is provided indicating how many elements are correct and in the correct position or correct but in the wrong position. 
The game ends when the player correctly guesses the code or runs out of attempts.

## Features
- Fully hardware-based implementation
- Modular Verilog design
- Finite State Machine controlled gameplay
- Debounced push-button inputs
- Visual feedback using LEDs and 7-segment displays
- Attempt tracking and game status indication
- Reset and replay functionality

## Module Overview
- top_module.v: Top-level module connecting all submodules
- mastermind.v: Core game logic and FSM implementation
- ssd.v: 7-segment display driver
- debouncer.v: Push-button debouncing module
- clk_divider.v: Clock divider for slower timing signals

## Finite State Machine
The game behavior is managed using a finite state machine that controls initialization, user input collection, guess evaluation, feedback display, win/lose conditions, and reset operations. 
All state transitions are synchronized with the system clock.

## Clocking and Timing
The main FPGA clock is divided into slower clock signals using a clock divider module. 
These slower clocks are used for display refreshing, input sampling, and stable game state transitions suitable for human interaction.

## Inputs and Outputs
Inputs include push buttons for control operations and switches for code or guess selection.
Outputs include LEDs for feedback and status indication and a 7-segment display for showing guesses, attempt counts, and game-related information.

## Verification and Testing
Each module was tested individually to ensure correct functionality. FSM transitions were verified through simulation and on-board testing was performed to confirm proper behavior of inputs, outputs, and game logic.

## How to Run
1. Open the project in an FPGA development tool such as Vivado.
2. Set top_module.v as the top-level module.
3. Apply the appropriate constraints file.
4. Synthesize and implement the design.
5. Program the FPGA board.
6. Use the onboard switches and buttons to play the game.

## Key Concepts Used
- Verilog HDL
- Finite State Machines
- Synchronous digital design
- Modular hardware architecture
- Clock division
- Input debouncing
- Display multiplexing

## Future Improvements
Possible future extensions include random code generation, difficulty levels, enhanced display interfaces such as VGA or LCD, audio feedback, and multiplayer support.

## Author
Abbas Kızıl
