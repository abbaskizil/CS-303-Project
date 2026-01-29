module mastermind(
    input clk,
    input rst, 
    input enterA, 
    input enterB,    
    input [2:0] letterIn,   
    output reg [7:0] LEDX,  
    output reg [7:0] SSD3,  
    output reg [7:0] SSD2, 
    output reg [7:0] SSD1,  
    output reg [7:0] SSD0  
    );

    parameter TIME_2SEC = 100;  // 50 Hz clock: 2 seconds = 100 cycles

    parameter S_START         = 5'd0;
    parameter S_SHOW_SCORE    = 5'd1;
    parameter S_SHOW_TURN     = 5'd2; 
    parameter S_MAKER_INPUT   = 5'd3;
    parameter S_SHOW_LIVES    = 5'd4; 
    parameter S_BREAKER_INPUT = 5'd5;
    parameter S_CHECK_GUESS   = 5'd6;
    parameter S_ROUND_WIN     = 5'd7;
    parameter S_ROUND_LOSE    = 5'd8;
    parameter S_WAIT          = 5'd9;
    parameter S_GAME_OVER     = 5'd10;
    parameter S_SHOW_SECRET   = 5'd11;

// 8-bit format
    parameter [7:0] CHAR_F    = 8'b01110001; 
    parameter [7:0] CHAR_A    = 8'b01110111; // CALISIYOR
    parameter [7:0] CHAR_b    = 8'b01111100; // CALISIYOR
    parameter [7:0] CHAR_C    = 8'b00111001; // CALISIYOR
    parameter [7:0] CHAR_E    = 8'b01111001; // CALISIYOR
    parameter [7:0] CHAR_H    = 8'b01110110; // CALISIYOR??
    parameter [7:0] CHAR_L    = 8'b00111000; // CALISIYOR??
    parameter [7:0] CHAR_U    = 8'b00111110; // CALISIYOR??
    parameter [7:0] CHAR_P    = 8'b01110011; // CALISIYOR
    parameter [7:0] CHAR_dash = 8'b01000000; // CALISIYOR
    parameter [7:0] CHAR_OFF  = 8'b00000000; // CALISIYOR

    parameter [7:0] NUM_0 = 8'b00111111; 
    parameter [7:0] NUM_1 = 8'b00000110; 
    parameter [7:0] NUM_2 = 8'b01011011; 
    parameter [7:0] NUM_3 = 8'b01001111;

    reg [4:0] state;             
    reg [4:0] next_state_save;   
    reg [7:0] delay_timer;       

    reg [1:0] scoreA;            
    reg [1:0] scoreB;            
    reg [1:0] lives;             
    reg [1:0] round_number;      
    reg       maker_is_A;        
    
    reg [2:0] secret1, secret2, secret3, secret4; 
    reg [2:0] guess1, guess2, guess3, guess4;     
    reg [2:0] input_count;       

    reg prev_enterA;
    reg prev_enterB;
    wire press_A;
    wire press_B;

    reg [1:0] res1, res2, res3, res4; 
    reg checked_this_guess;
    reg [7:0] LEDX_hold;

    reg [3:0] secret_used;
    reg [3:0] guess_used;

    wire valid_turn_press;
    wire valid_breaker_press;

    reg [7:0] blink_counter;

    assign press_A = (enterA == 1 && prev_enterA == 0);
    assign press_B = (enterB == 1 && prev_enterB == 0);

    assign valid_turn_press = (maker_is_A == 1 && press_A) || (maker_is_A == 0 && press_B);
    assign valid_breaker_press = (maker_is_A == 1 && press_B) || (maker_is_A == 0 && press_A);

    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin 
            state <= S_START;
            scoreA <= 0;
            scoreB <= 0;
            round_number <= 0;
            lives <= 3;
            maker_is_A <= 1; 
            input_count <= 0;
            delay_timer <= 0;
            prev_enterA <= 0;
            prev_enterB <= 0;
            next_state_save <= S_START;
            secret1 <= 0; secret2 <= 0; secret3 <= 0; secret4 <= 0;
            guess1 <= 0; guess2 <= 0; guess3 <= 0; guess4 <= 0;
            blink_counter <= 0;
            checked_this_guess <= 0;
            LEDX_hold <= 8'b00000000;
        end 
        else begin
            prev_enterA <= enterA;
            prev_enterB <= enterB;

            if (delay_timer > 0) 
            begin
                delay_timer <= delay_timer - 1;
            end

            case (state)

                S_START: 
                begin
                    if (press_A) 
                    begin
                        maker_is_A <= 1; 
                        state <= S_SHOW_SCORE;
                        delay_timer <= TIME_2SEC;
                    end
                    else if (press_B) 
                    begin
                        maker_is_A <= 0; 
                        state <= S_SHOW_SCORE;
                        delay_timer <= TIME_2SEC;
                    end
                end

                S_SHOW_SCORE: 
                begin
                    if (delay_timer == 0) 
                    begin
                        state <= S_SHOW_TURN;
                        delay_timer <= TIME_2SEC;
                    end
                end

                S_SHOW_TURN: 
                begin
                    input_count <= 0; 
                    guess1 <= 0; guess2 <= 0; guess3 <= 0; guess4 <= 0;
                    LEDX_hold <= 8'b00000000;
                    if (delay_timer == 0) 
                    begin
                        state <= S_MAKER_INPUT;
                    end
                end

                S_MAKER_INPUT: 
                begin
                    if (valid_turn_press && (letterIn != 3'b000)) 
                    begin
                        if (input_count == 0) begin secret1 <= letterIn; end
                        if (input_count == 1) begin secret2 <= letterIn; end
                        if (input_count == 2) begin secret3 <= letterIn; end
                        if (input_count == 3) begin secret4 <= letterIn; end

                        if (input_count == 3) 
                        begin
                            state <= S_SHOW_LIVES;
                            delay_timer <= TIME_2SEC;
                            lives <= 3; 
                        end 
                        else 
                        begin
                            input_count <= input_count + 1;
                            state <= S_WAIT;
                            next_state_save <= S_MAKER_INPUT;
                        end
                    end
                end

                S_WAIT: 
                begin
                    state <= next_state_save;
                end

                S_SHOW_LIVES: 
                begin
                    input_count <= 0;
                    checked_this_guess <= 0;
                    guess1 <= 0;
                    guess2 <= 0;
                    guess3 <= 0;
                    guess4 <= 0;
                    LEDX_hold <= 8'b00000000;
                    if (delay_timer == 0) 
                    begin
                        state <= S_BREAKER_INPUT;
                    end
                end

                S_BREAKER_INPUT: begin
                    if (valid_breaker_press && (letterIn != 3'b000)) 
                    begin
                        if (input_count == 0) begin guess1 <= letterIn; end
                        if (input_count == 1) begin guess2 <= letterIn; end
                        if (input_count == 2) begin guess3 <= letterIn; end
                        if (input_count == 3) begin 
                            guess4 <= letterIn;
                            input_count <= 0;
                            checked_this_guess <= 0;
                            state <= S_CHECK_GUESS;
                            delay_timer <= TIME_2SEC;
                        end 
                        else 
                        begin
                            input_count <= input_count + 1;
                            state <= S_WAIT;
                            next_state_save <= S_BREAKER_INPUT;
                        end
                    end
                end

                S_CHECK_GUESS: begin
                    if (!checked_this_guess) begin
                        checked_this_guess <= 1;
                        LEDX_hold <= {res1, res2, res3, res4};
                    end
                    if(delay_timer == 0) begin
                        if (res1 == 2'b11 && res2 == 2'b11 && res3 == 2'b11 && res4 == 2'b11) 
                        begin
                            if (maker_is_A == 1) begin scoreB <= scoreB + 1; end
                            else begin scoreA <= scoreA + 1; end
                            state <= S_ROUND_WIN;
                            delay_timer <= TIME_2SEC;
                        end 
                        else 
                        begin
                            if (lives > 1) 
                            begin
                                lives <= lives - 1;
                                state <= S_SHOW_LIVES; 
                                delay_timer <= TIME_2SEC;
                            end 
                            else 
                            begin
                                if (maker_is_A == 1) begin scoreA <= scoreA + 1; end
                                else begin scoreB <= scoreB + 1; end
                                state <= S_SHOW_SECRET;
                                delay_timer <= TIME_2SEC;
                            end
                        end
                    end
                end

                S_SHOW_SECRET:
                begin
                    if (delay_timer == 0)
                    begin
                        state <= S_ROUND_LOSE;
                        delay_timer <= TIME_2SEC;
                    end
                end

                S_ROUND_WIN: 
                begin
                    if (delay_timer == 0) 
                    begin
                        if (scoreA == 2 || scoreB == 2) 
                        begin
                            state <= S_GAME_OVER;
                        end 
                        else 
                        begin
                            maker_is_A <= ~maker_is_A; 
                            if (round_number == 2) begin
                                state <= S_GAME_OVER;
                            end 
                            else 
                            begin
                                round_number <= round_number + 1;
                                state <= S_SHOW_SCORE;
                                delay_timer <= TIME_2SEC;
                            end
                        end
                    end
                end

                S_ROUND_LOSE: 
                begin
                    if (delay_timer == 0) 
                    begin
                        if (scoreA == 2 || scoreB == 2) 
                        begin
                            state <= S_GAME_OVER;
                        end 
                        else 
                        begin
                            maker_is_A <= ~maker_is_A;
                            if (round_number == 2) 
                            begin
                                state <= S_GAME_OVER;
                            end 
                            else 
                            begin
                                round_number <= round_number + 1;
                                state <= S_SHOW_SCORE;
                                delay_timer <= TIME_2SEC;
                            end
                        end
                    end
                end

                S_GAME_OVER: 
                begin
                    blink_counter <= blink_counter + 1;

                    if (press_A || press_B) 
                    begin
                        state <= S_START;
                        scoreA <= 0;
                        scoreB <= 0;
                        round_number <= 0;
                        lives <= 3;
                        input_count <= 0;
                        blink_counter <= 0;
                        checked_this_guess <= 0;
                        LEDX_hold <= 8'b00000000;
                    end
                end
            endcase
        end
    end

    // Mastermind scoring with duplicate handling
    always @(*) begin
        res1 = 2'b00; res2 = 2'b00; res3 = 2'b00; res4 = 2'b00;

        // Mark exact matches and then checking each part
        if (guess1 == secret1) begin 
            res1 = 2'b11; 
            secret_used[0] = 1; 
            guess_used[0] = 1; 
        end
        else if ((guess1 == secret2) || (guess1 == secret3) || (guess1 == secret4))begin
            res1 = 2'b01;
        end
        else 
            res1 = 2'b00;

        if (guess2 == secret2) 
            res2 = 2'b11; 
        else if ((guess2 == secret1) || (guess2 == secret3) || (guess2 == secret4)) 
            res2 = 2'b01; 
        else 
            res2 = 2'b00;

        if (guess3 == secret3) 
            res3 = 2'b11; 
        else if ((guess3 == secret1) || (guess3 == secret2) || (guess3 == secret4)) 
            res3 = 2'b01; 
        else 
            res3 = 2'b00;

        if (guess4 == secret4) 
            res4 = 2'b11; 
        else if ((guess4 == secret1) || (guess4 == secret2) || (guess4 == secret3)) 
            res4 = 2'b01; 
        else 
            res4 = 2'b00;

     end
    // SSD Display Logic
    always @(*) begin
        SSD3 = CHAR_OFF;
        SSD2 = CHAR_OFF;
        SSD1 = CHAR_OFF;
        SSD0 = CHAR_OFF;
        
        case (state)
            S_START: begin
                SSD2 = CHAR_A;
                SSD1 = CHAR_dash;
                SSD0 = CHAR_b;
            end
            
            S_SHOW_SCORE, S_ROUND_WIN, S_ROUND_LOSE: begin
                case(scoreA)
                    2'd0: SSD2 = NUM_0;
                    2'd1: SSD2 = NUM_1;
                    2'd2: SSD2 = NUM_2;
                    default: SSD2 = NUM_0;
                endcase
                SSD1 = CHAR_dash;
                case(scoreB)
                    2'd0: SSD0 = NUM_0;
                    2'd1: SSD0 = NUM_1;
                    2'd2: SSD0 = NUM_2;
                    default: SSD0 = NUM_0;
                endcase
            end
            
            S_SHOW_TURN: begin
                SSD2 = CHAR_P;
                SSD1 = CHAR_dash;
                if (maker_is_A) begin
                    SSD0 = CHAR_A;
                end 
                else begin
                    SSD0 = CHAR_b;
                end
            end
            
            S_MAKER_INPUT: begin
                case(input_count)
                    3'd0: begin
                        case(letterIn)
                            3'b000: SSD3 = CHAR_dash;
                            3'b001: SSD3 = CHAR_A;
                            3'b010: SSD3 = CHAR_C;
                            3'b011: SSD3 = CHAR_E;
                            3'b100: SSD3 = CHAR_F;
                            3'b101: SSD3 = CHAR_H;
                            3'b110: SSD3 = CHAR_L;
                            3'b111: SSD3 = CHAR_U;
                            default: SSD3 = CHAR_OFF;
                        endcase
                        SSD2 = CHAR_OFF;
                        SSD1 = CHAR_OFF;
                        SSD0 = CHAR_OFF;
                    end
                    3'd1: begin
                        SSD3 = CHAR_dash;
                        case(letterIn)
                            3'b000: SSD2 = CHAR_dash;
                            3'b001: SSD2 = CHAR_A;
                            3'b010: SSD2 = CHAR_C;
                            3'b011: SSD2 = CHAR_E;
                            3'b100: SSD2 = CHAR_F;
                            3'b101: SSD2 = CHAR_H;
                            3'b110: SSD2 = CHAR_L;
                            3'b111: SSD2 = CHAR_U;
                            default: SSD2 = CHAR_OFF;
                        endcase
                        SSD1 = CHAR_OFF;
                        SSD0 = CHAR_OFF;
                    end
                    3'd2: begin
                        SSD3 = CHAR_dash;
                        SSD2 = CHAR_dash;
                        case(letterIn)
                            3'b000: SSD1 = CHAR_dash;
                            3'b001: SSD1 = CHAR_A;
                            3'b010: SSD1 = CHAR_C;
                            3'b011: SSD1 = CHAR_E;
                            3'b100: SSD1 = CHAR_F;
                            3'b101: SSD1 = CHAR_H;
                            3'b110: SSD1 = CHAR_L;
                            3'b111: SSD1 = CHAR_U;
                            default: SSD1 = CHAR_OFF;
                        endcase
                        SSD0 = CHAR_OFF;
                    end
                    3'd3: begin
                        SSD3 = CHAR_dash;
                        SSD2 = CHAR_dash;
                        SSD1 = CHAR_dash;
                        case(letterIn)
                            3'b000: SSD0 = CHAR_dash;
                            3'b001: SSD0 = CHAR_A;
                            3'b010: SSD0 = CHAR_C;
                            3'b011: SSD0 = CHAR_E;
                            3'b100: SSD0 = CHAR_F;
                            3'b101: SSD0 = CHAR_H;
                            3'b110: SSD0 = CHAR_L;
                            3'b111: SSD0 = CHAR_U;
                            default: SSD0 = CHAR_OFF;
                        endcase
                    end
                    default: begin
                        SSD3 = CHAR_OFF;
                        SSD2 = CHAR_OFF;
                        SSD1 = CHAR_OFF;
                        SSD0 = CHAR_OFF;
                    end
                endcase
            end
            
            S_SHOW_LIVES: begin
                SSD2 = CHAR_L;
                SSD1 = CHAR_dash;
                case(lives)
                    2'd3: SSD0 = NUM_3;
                    2'd2: SSD0 = NUM_2;
                    2'd1: SSD0 = NUM_1;
                    default: SSD0 = NUM_0;
                endcase
            end
            
            S_BREAKER_INPUT, S_CHECK_GUESS: begin
                
                // First Letter
                // If we are currently typing the 1st letter, show the letterIn
                if (state == S_BREAKER_INPUT && input_count == 0) begin
                    case(letterIn)
                        3'b000: SSD3 = CHAR_dash;
                        3'b001: SSD3 = CHAR_A;
                        3'b010: SSD3 = CHAR_C;
                        3'b011: SSD3 = CHAR_E;
                        3'b100: SSD3 = CHAR_F;
                        3'b101: SSD3 = CHAR_H;
                        3'b110: SSD3 = CHAR_L;
                        3'b111: SSD3 = CHAR_U;
                        default: SSD3 = CHAR_OFF;
                    endcase
                end 
                // Otherwise, show what is saved in memory (guess1)
                else begin
                    case(guess1)
                        3'b000: SSD3 = CHAR_dash;
                        3'b001: SSD3 = CHAR_A;
                        3'b010: SSD3 = CHAR_C;
                        3'b011: SSD3 = CHAR_E;
                        3'b100: SSD3 = CHAR_F;
                        3'b101: SSD3 = CHAR_H;
                        3'b110: SSD3 = CHAR_L;
                        3'b111: SSD3 = CHAR_U;
                        default: SSD3 = CHAR_OFF;
                    endcase
                end

                // second letter
                if (state == S_BREAKER_INPUT && input_count == 1) begin
                    case(letterIn)
                        3'b000: SSD2 = CHAR_dash;
                        3'b001: SSD2 = CHAR_A;
                        3'b010: SSD2 = CHAR_C;
                        3'b011: SSD2 = CHAR_E;
                        3'b100: SSD2 = CHAR_F;
                        3'b101: SSD2 = CHAR_H;
                        3'b110: SSD2 = CHAR_L;
                        3'b111: SSD2 = CHAR_U;
                        default: SSD2 = CHAR_OFF;
                    endcase
                end 
                else begin
                    case(guess2)
                        3'b000: SSD2 = CHAR_dash;
                        3'b001: SSD2 = CHAR_A;
                        3'b010: SSD2 = CHAR_C;
                        3'b011: SSD2 = CHAR_E;
                        3'b100: SSD2 = CHAR_F;
                        3'b101: SSD2 = CHAR_H;
                        3'b110: SSD2 = CHAR_L;
                        3'b111: SSD2 = CHAR_U;
                        default: SSD2 = CHAR_OFF;
                    endcase
                end

                //Third Letter
                if (state == S_BREAKER_INPUT && input_count == 2) begin
                    case(letterIn)
                        3'b000: SSD1 = CHAR_dash;
                        3'b001: SSD1 = CHAR_A;
                        3'b010: SSD1 = CHAR_C;
                        3'b011: SSD1 = CHAR_E;
                        3'b100: SSD1 = CHAR_F;
                        3'b101: SSD1 = CHAR_H;
                        3'b110: SSD1 = CHAR_L;
                        3'b111: SSD1 = CHAR_U;
                        default: SSD1 = CHAR_OFF;
                    endcase
                end 
                else begin
                    case(guess3)
                        3'b000: SSD1 = CHAR_dash;
                        3'b001: SSD1 = CHAR_A;
                        3'b010: SSD1 = CHAR_C;
                        3'b011: SSD1 = CHAR_E;
                        3'b100: SSD1 = CHAR_F;
                        3'b101: SSD1 = CHAR_H;
                        3'b110: SSD1 = CHAR_L;
                        3'b111: SSD1 = CHAR_U;
                        default: SSD1 = CHAR_OFF;
                    endcase
                end

                // Forth Letter
                if (state == S_BREAKER_INPUT && input_count == 3) begin
                    case(letterIn)
                        3'b000: SSD0 = CHAR_dash;
                        3'b001: SSD0 = CHAR_A;
                        3'b010: SSD0 = CHAR_C;
                        3'b011: SSD0 = CHAR_E;
                        3'b100: SSD0 = CHAR_F;
                        3'b101: SSD0 = CHAR_H;
                        3'b110: SSD0 = CHAR_L;
                        3'b111: SSD0 = CHAR_U;
                        default: SSD0 = CHAR_OFF;
                    endcase
                end 
                else begin
                    case(guess4)
                        3'b000: SSD0 = CHAR_dash;
                        3'b001: SSD0 = CHAR_A;
                        3'b010: SSD0 = CHAR_C;
                        3'b011: SSD0 = CHAR_E;
                        3'b100: SSD0 = CHAR_F;
                        3'b101: SSD0 = CHAR_H;
                        3'b110: SSD0 = CHAR_L;
                        3'b111: SSD0 = CHAR_U;
                        default: SSD0 = CHAR_OFF;
                    endcase
                end

            end
            
            S_SHOW_SECRET: begin
                case(secret1)
                    3'b000: SSD3 = CHAR_dash;
                    3'b001: SSD3 = CHAR_A;
                    3'b010: SSD3 = CHAR_C;
                    3'b011: SSD3 = CHAR_E;
                    3'b100: SSD3 = CHAR_F;
                    3'b101: SSD3 = CHAR_H;
                    3'b110: SSD3 = CHAR_L;
                    3'b111: SSD3 = CHAR_U;
                    default: SSD3 = CHAR_OFF;
                endcase
                case(secret2)
                    3'b000: SSD2 = CHAR_dash;
                    3'b001: SSD2 = CHAR_A;
                    3'b010: SSD2 = CHAR_C;
                    3'b011: SSD2 = CHAR_E;
                    3'b100: SSD2 = CHAR_F;
                    3'b101: SSD2 = CHAR_H;
                    3'b110: SSD2 = CHAR_L;
                    3'b111: SSD2 = CHAR_U;
                    default: SSD2 = CHAR_OFF;
                endcase
                case(secret3)
                    3'b000: SSD1 = CHAR_dash;
                    3'b001: SSD1 = CHAR_A;
                    3'b010: SSD1 = CHAR_C;
                    3'b011: SSD1 = CHAR_E;
                    3'b100: SSD1 = CHAR_F;
                    3'b101: SSD1 = CHAR_H;
                    3'b110: SSD1 = CHAR_L;
                    3'b111: SSD1 = CHAR_U;
                    default: SSD1 = CHAR_OFF;
                endcase
                case(secret4)
                    3'b000: SSD0 = CHAR_dash;
                    3'b001: SSD0 = CHAR_A;
                    3'b010: SSD0 = CHAR_C;
                    3'b011: SSD0 = CHAR_E;
                    3'b100: SSD0 = CHAR_F;
                    3'b101: SSD0 = CHAR_H;
                    3'b110: SSD0 = CHAR_L;
                    3'b111: SSD0 = CHAR_U;
                    default: SSD0 = CHAR_OFF;
                endcase
            end
            
            S_GAME_OVER: begin
                SSD3 = CHAR_OFF;
                case(scoreA) 
                    2'd0: SSD2 = NUM_0; 
                    2'd1: SSD2 = NUM_1; 
                    2'd2: SSD2 = NUM_2; 
                    default: SSD2 = NUM_0; 
                endcase
                
                
                SSD1 = CHAR_dash;
                
                // Display Player B Score
                case(scoreB) 
                    2'd0: SSD0 = NUM_0; 
                    2'd1: SSD0 = NUM_1; 
                    2'd2: SSD0 = NUM_2; 
                    default: SSD0 = NUM_0; 
                endcase
            end
            
            default: begin
                SSD3 = CHAR_OFF;
                SSD2 = CHAR_OFF;
                SSD1 = CHAR_OFF;
                SSD0 = CHAR_OFF;
            end
        endcase
    end

    // LED Logic
    always @(*) begin
        if (state == S_CHECK_GUESS) begin
            LEDX = {res1, res2, res3, res4};
        end
        else if (state == S_BREAKER_INPUT || state == S_SHOW_LIVES) begin
            LEDX = LEDX_hold;
        end
        else if (state == S_GAME_OVER) begin
            if (blink_counter[4] == 1) begin
                LEDX = 8'hFF; // All LEDs ON
            end 
            else begin
                LEDX = 8'h00; // All LEDs OFF
            end
        end
        else begin
            LEDX = 8'b00000000;
        end
    end

endmodule