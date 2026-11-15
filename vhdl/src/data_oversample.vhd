-- Date: 11/11/26
-- Author : Amit S. 
-- Design description:
--
-- 
--        This design performs x4 oversampling of same data input copies
--        shifted by 45 degree. 
--        The same data input is passed to master ISERDES
--        while the shifted copy of it passed to slave ISERDES. 
--        A 45° phase shift between master and slave ISERDES data inputs
--        guarantees that at least one rising data edge will be 
--        sampled correctly by either the Master or Slave ISERDES. 
--        even if one of the sampling edges (Master or Slave ISERDES) 
--        occurs too close to a data transition and violates setup/hold 
--        timing, the other sampling edge will be sufficiently far 
--        from the transition to capture the data reliably.   
--


library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


entity data_oversample is

port(
    -- inputs
    din_p           : in std_logic;
    din_n           : in std_logic;
    clk100          : in std_logic;
    clk100_rst      : in std_logic;
    clk100_ph90     : in std_logic;
    clk200          : in std_logic;
    clk200_rst      : in std_logic;
    -- outputs
    time_cnt        : out std_logic_vector(63 downto 0);
    Q1M             : out std_logic;
    Q2M             : out std_logic;
    Q3M             : out std_logic;
    Q4M             : out std_logic;
    Q4M_prev        : out std_logic;
    Q1S             : out std_logic;
    Q2S             : out std_logic;
    Q3S             : out std_logic;
    Q4S             : out std_logic;
    Q4S_prev        : out std_logic

);

end entity;


architecture arc of data_oversample is
    begin

end arc;