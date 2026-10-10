----------------------------------------------------------------------------------
-- This file is based on the official Red Pitaya FPGA moving average example.
-- Original project: https://github.com/RedPitaya/RedPitaya-FPGA
--
-- Original copyright:
-- Copyright (c) 2014, Red Pitaya, d.o.o.
--
-- Modified by: Ming-Feng Cao
-- Modification:
--   1. Changed the original tag-controlled moving average filter
--      into a fixed 512-tap moving average filter.
--   2. Increased accumulator width to 26 bits to prevent overflow.
--   3. Implemented rolling sum with a circular buffer.
--   4. Verified the filter using an external signal generator and oscilloscope.
--
-- This project is not officially endorsed by Red Pitaya.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity moving_average is
    Port ( data_i   : in std_logic_vector (13 downto 0);    -- adc input data
           clk_i    : in std_logic;                         -- bus clock
           rstn_i   : in std_logic;                         -- bus reset - active low
           tag_i    : in unsigned (1 downto 0);             -- kept for compatibility, not used in fixed 512-tap version
           data_o   : out std_logic_vector (13 downto 0));  -- filtered data
end moving_average;

architecture Behavioral of moving_average is

    constant N : integer := 512;

    type mem_t is array (0 to N-1) of signed(13 downto 0);

    signal regs   : mem_t := (others => (others => '0'));
    signal sum    : signed(25 downto 0) := (others => '0');
    signal wr_idx : integer range 0 to N-1 := 0;

begin

process(clk_i)
    variable x_new    : signed(13 downto 0);
    variable x_old    : signed(13 downto 0);
    variable sum_next : signed(25 downto 0);
begin
    if rising_edge(clk_i) then
        if rstn_i = '0' then
            regs   <= (others => (others => '0'));
            sum    <= (others => '0');
            wr_idx <= 0;
            data_o <= (others => '0');

        else
            -- Current input sample
            x_new := signed(data_i);

            -- Oldest sample in the circular buffer
            x_old := regs(wr_idx);

            -- Rolling sum:
            -- new sum = previous sum + new sample - oldest sample
            sum_next := sum + resize(x_new, 26) - resize(x_old, 26);

            -- Store the new sample into the circular buffer
            regs(wr_idx) <= x_new;

            -- Update accumulated sum
            sum <= sum_next;

            -- Divide by 512 using a 9-bit right shift
            data_o <= std_logic_vector(
                resize(shift_right(sum_next, 9), 14)
            );

            -- Circular buffer index update
            if wr_idx = N-1 then
                wr_idx <= 0;
            else
                wr_idx <= wr_idx + 1;
            end if;

        end if;
    end if;
end process;

end Behavioral;
