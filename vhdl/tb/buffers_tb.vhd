-- Date: 11/11/26
-- Author : Amit S. 
-- Design description:
--
--      Testbench for buffers block
--

library ieee;
use ieee.std_logic_1164.all;


entity buffers_tb is
end entity;

architecture arc of buffers_tb is

component buffers is
    port (
        sys_clk_100MHz_p : in std_logic;   -- positive input of LVDS clock
        sys_clk_100MHz_n : in std_logic;   -- negative input of LVDS clock
        sys_rst          : in std_logic;
        clk100           : out std_logic;  -- clock 100MHz 
        clk100_rst       : out std_logic;  -- reset syncronized to clk 100MHz
        clk100_ph90      : out std_logic;  -- clock 100Mhz with 90 degree phase
        clk200           : out std_logic;  -- clock 200MHz
        clk200_rst       : out std_logic   -- reset synchronized with clock 200Mhz
        
    );
end component;


signal sys_clk_100MHz_p    : std_logic := '0';
signal sys_clk_100MHz_n    : std_logic := '1';
signal sys_rst             : std_logic := '0';
signal clk100              : std_logic;
signal clk100_rst          : std_logic;
signal clk100_ph90         : std_logic;
signal clk200              : std_logic;
signal clk200_rst          : std_logic;






constant C_CLK_PERIOD : time := 10 ns;
constant C_HALF_CLK_PERIOD : time := C_CLK_PERIOD/2;
constant C_RESET_TIME : time := 30 ns;

begin

process 
begin
    wait for C_HALF_CLK_PERIOD;
    sys_clk_100MHz_p <= not sys_clk_100MHz_p;
    sys_clk_100MHz_n <= not sys_clk_100MHz_n;
    
end process;


process 
begin
    wait for C_RESET_TIME;
        sys_rst  <= '1';
    
end process;


buffers_inst: buffers 
    port map (
        sys_clk_100MHz_p => sys_clk_100MHz_p,    -- positive input of LVDS clock
        sys_clk_100MHz_n => sys_clk_100MHz_n,    -- negative input of LVDS clock
        sys_rst          => sys_rst     ,
        clk100           => clk100      ,        -- clock 100MHz 
        clk100_rst       => clk100_rst  ,        -- reset syncronized to clk 100MHz
        clk100_ph90      => clk100_ph90 ,        -- clock 100Mhz with 90 degree phase
        clk200           => clk200      ,        -- clock 200MHz
        clk200_rst       => clk200_rst           -- reset synchronized with clock 200Mhz
        
    );

    
    
end architecture;    

