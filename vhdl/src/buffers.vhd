-- Date: 11/11/26
-- Author : Amit S. 
-- Design description:
--
-- 
--        this design includes clocks generation 
--        and their reset syncronizers
--



library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity buffers is
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
end entity;


architecture arc of buffers is


    component rst_sync_r is
        generic (
            G_STAGES_NUM : positive := 3         -- Number of synchronization FFs
        );
        port ( 
            clk              : in  std_logic;   -- clock for reset synchronization
            rst_async_in     : in  std_logic;   -- Asynchronous reset input  (active high)
            rst_sync_out_r   : out std_logic    -- Synchronized reset output (active high)
        );
    end component;


    signal sys_clk_100MHz_u : std_logic;
    signal sys_clk_100MHz   : std_logic;
    signal pll_locked       : std_logic;
    signal clkfbout_u       : std_logic; -- u stands for unbuffered
    signal clkfbout         : std_logic;
    signal clk100_u         : std_logic;  
    signal clk200_u         : std_logic;          
    signal clk100_ph90_u    : std_logic;
    signal rst_comb         : std_logic;
    signal sys_rst_p        : std_logic;
    signal clk100_sig       : std_logic;
    signal clk200_sig       : std_logic;

    begin



    -- IBUFDS: Differential Input Buffer
    ibufds_inst : IBUFDS
        generic map (
            DIFF_TERM => FALSE,     -- Differential Termination
            IBUF_LOW_PWR => FALSE,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD => "LVDS")
        port map (
            I =>  sys_clk_100MHz_p,  -- Diff_p buffer input (connect directly to top-level port)
            IB => sys_clk_100MHz_n,  -- Diff_n buffer input (connect directly to top-level port)            
            O =>  sys_clk_100MHz_u   -- Buffer output
        );


    -- BUFG: Global Clock Simple Buffer 
    sys_clk100_bufg_inst : BUFG    
        port map (
            I => sys_clk_100MHz_u, -- 1-bit input: Clock input
            O => sys_clk_100MHz    -- 1-bit output: Clock output

        );-- End of BUFG_inst instantiation



    -- PLLE2_BASE: Base Phase Locked Loop (PLL)
    -- Fvco = Fclkin x M/D
    -- Fout = Fvco/O_1..7
    plle2_base_inst : PLLE2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
        CLKFBOUT_MULT => 10,       -- Multiply value for all CLKOUT, (2-64)
        CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
        CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT0_DIVIDE => 10,
        CLKOUT1_DIVIDE => 10,
        CLKOUT2_DIVIDE => 5,
        CLKOUT3_DIVIDE => 1,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT5_DUTY_CYCLE => 0.5,
        -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 90.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        CLKOUT5_PHASE => 0.0,
        DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
        REF_JITTER1   => 0.001,    -- Reference input jitter in UI, (0.000-0.999).
        STARTUP_WAIT => "TRUE"     -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0  => clk100_u,        -- 1-bit output: CLKOUT0
        CLKOUT1  => clk100_ph90_u,  -- 1-bit output: CLKOUT1
        CLKOUT2  => clk200_u,        -- 1-bit output: CLKOUT2
        CLKOUT3  => open,            -- 1-bit output: CLKOUT3
        CLKOUT4  => open,            -- 1-bit output: CLKOUT4
        CLKOUT5  => open,            -- 1-bit output: CLKOUT5
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => clkfbout_u,      -- 1-bit output: Feedback clock
        LOCKED   => pll_locked,      -- 1-bit output: LOCK
        CLKIN1   => sys_clk_100MHz,  -- 1-bit input: Input clock
        -- Control Ports: 1-bit (each) input: PLL control ports
        PWRDWN   => '0',             -- 1-bit input: Power-down
        RST      => sys_rst_p,     -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN  => clkfbout         -- 1-bit input: Feedback clock
    );
    
        -- combined reset from sys and pll:
        rst_comb  <= not (pll_locked and sys_rst);
        
        -- sys_rst is active low signal
        sys_rst_p <= not sys_rst;

    feedback_bufg_inst : BUFG    
        port map (
            I => clkfbout_u, -- 1-bit input: Clock input
            O => clkfbout    -- 1-bit output: Clock output

        );   

    
    clk100_bufg_inst : BUFG
        port map (
            I => clk100_u,
            O => clk100_sig
        ); 

    clk100 <= clk100_sig;

    clk100_ph90_bufg_inst : BUFG
        port map (
            I => clk100_ph90_u,
            O => clk100_ph90
        );     
    
    clk200_bufg_inst : BUFG
        port map (
            I => clk200_u,
            O => clk200_sig
        );
        
    clk200 <= clk200_sig;    



    rst_sync_inst_100MHz:  rst_sync_r 
        generic map (
            G_STAGES_NUM => 3         -- Number of synchronization FFs
        )
        port map ( 
            clk              => clk100_sig,         -- clock for reset synchronization
            rst_async_in     => rst_comb,       -- Asynchronous reset input  (active high)
            rst_sync_out_r   => clk100_rst      -- Synchronized reset output (active high)
        );


    rst_sync_inst_200MHz:  rst_sync_r 
        generic map (
            G_STAGES_NUM => 3         -- Number of synchronization FFs
        )
        port map ( 
            clk              => clk200_sig,         -- clock for reset synchronization
            rst_async_in     => rst_comb,       -- Asynchronous reset input  (active high)
            rst_sync_out_r   => clk200_rst      -- Synchronized reset output (active high)
        );


end architecture;    
