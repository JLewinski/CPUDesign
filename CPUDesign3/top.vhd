﻿library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;
    use IEEE.std_logic_arith.sxt;

entity top is
    port(
        output :out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity;

architecture behavior of top is
    component Register16 is
        port(
            dataIn :in STD_LOGIC_VECTOR(15 downto 0);
            CLK, WE, RST :in STD_LOGIC;
            dataOut :out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component ALU is
        port(
            CLK, RST :in std_logic;
            i_setting :in std_logic_vector(1 downto 0);
            i_dataA, i_DataB :in STD_LOGIC_VECTOR(15 downto 0);
            o_data :out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component Control is
        port(
            instruction :in std_logic_vector (3 downto 0);
            clk, rst :in std_logic;
            jump, branch, mem2Reg, memW, ri, regW, selDest :out std_logic;
            aluOut : out std_logic_vector(1 downto 0)
        );
    end component;

    --component Memory is
    --    generic (
    --        DATA_WIDTH        : integer := 16;
    --        ADDRESS_WIDTH    : integer := 16
    --    );
    --    port ( 
    --        CLK     : in  STD_LOGIC;
    --        Reset     : in  STD_LOGIC;
    --        DataIn     : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    --        Address    : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
    --        WriteEn    : in  STD_LOGIC;
    --        Enable     : in  STD_LOGIC;
    --        DataOut     : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    --    );
    --end component;
    
    component FullMemory is
        port ( 
            CLK, WE, RST        : in  STD_LOGIC;
            DataIn              : in  STD_LOGIC_VECTOR (15 downto 0);
            InstAddr, DataAddr  : in  STD_LOGIC_VECTOR (15 downto 0);
            InstOut, DataOut     : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;

    component RegisterMemory is
        generic (
            DATA_WIDTH        : integer := 16;
            ADDRESS_WIDTH    : integer := 4
        );
        port ( 
            DataIn                          : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
            SourceA, SourceB, DestAddr      : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
            WriteEn, CLK, RST               : in  STD_LOGIC;
            DataOutA, DataOutB              : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
        );
    end component;

    component Mux_2_To_1 is
        generic (
            d_WIDTH : integer := 1
        );
        port(
            i_Select, CLK, RST :in std_logic;
            i_Data1, i_Data2 :in std_logic_vector(d_WIDTH downto 0);
            o_Data :out std_logic_vector(d_WIDTH downto 0)
        );
    end component;

    signal RST : STD_LOGIC := '1';
    signal fstCLK, sysCLK : STD_LOGIC;
    constant clk_period : time := 1 ns;

    --PC
    signal pcIn, pcOut, pcPlus4, pcALUOut, calcPC, pcExt : STD_LOGIC_VECTOR(15 downto 0);

    --Instruction
    signal instruction, instructionExt : STD_LOGIC_VECTOR(15 downto 0);

    --REGISTERS
    signal regA, regB, regD : STD_LOGIC_VECTOR(15 downto 0);
    signal destAddr : STD_LOGIC_VECTOR(3 downto 0);
    signal constValue : STD_LOGIC;


    --CONTROL
    signal jump, branch, mem2Reg, memW, ri, regW, selDest : std_logic;
    signal aluSetting : std_logic_vector(1 downto 0);

    --ALU
    signal aluIn2, aluResult : STD_LOGIC_VECTOR(15 downto 0);

    --DATA
    signal memOut : STD_LOGIC_VECTOR(15 downto 0);

begin
    output <= PCout;

    fst_clk_process :process
    begin
        fstCLK <= not fstCLK after clk_period;
    end process;

    sl_clk_process :process
    begin
        sysCLK <= not sysCLK after clk_period * 10;
    end process;
    
    rst_process :process
    begin
        RST <= '0' after clk_period * 20;
    end process;
    
    PC: Register16 port map(
        dataIn => pcIn,
        CLK => sysCLK,
        WE => '1',
        RST => RST,
        dataOut => pcOut);
    
    --InstructionMemory: Memory port map(
    --    CLK => fstCLK,
    --    Reset => RST,
    --    DataIn => "0000000000000000",
    --    Address => pcOut,
    --    WriteEn => '0',
    --    Enable => '1',
    --    DataOut => instruction);
    
    CTRL: Control port map(
        instruction => instruction(15 downto 12),
        clk => fstCLK,
        rst => RST,
        jump => jump,
        branch => branch,
        mem2Reg => mem2Reg,
        memW => memW,
        ri => ri,
        regW => regW,
        selDest => selDest,
        aluOut => aluSetting);
    
    DestRegMux: Mux_2_To_1 generic map(d_Width => 16) port map(
        i_Select => selDest,
        CLK => fstCLK,
        RST => RST,
        i_Data1 => instruction(7 downto 4),
        i_Data2 => instruction(3 downto 0),
        o_Data => destAddr);
    
    Registers: RegisterMemory port map(
        DataIn => regD,
        SourceA => instruction(11 downto 8),
        SourceB => instruction(7 downto 4),
        DestAddr => destAddr,
        WriteEn => regW,
        CLK => fstCLK,
        RST => RST,
        DataOutA => regA,
        DataOutB => regB);
    
    ConstMux: Mux_2_To_1 generic map(d_Width => 4) port map(
        i_Select => branch,
        CLK => fstCLK,
        RST => RST,
        i_Data1 => instruction(3 downto 0),
        i_Data2 => "0000",
        o_Data => constValue);
    
    ALUMux: Mux_2_To_1 generic map(d_Width => 16) port map(
        i_Select => ri,
        CLK => fstCLK,
        RST => RST,
        i_Data1 => regB,
        i_Data2 => SXT(constValue, 16),
        o_Data => aluIn2);
    
    FullALU: ALU port map(
        i_setting => aluSetting,
        CLK => fstCLK,
        RST => RST,
        i_dataA => regA,
        i_dataB => aluIn2,
        o_data => aluResult);
    
    --DataMemory: Memory port map(
    --    CLK => fstCLK,
    --    Reset => RST,
    --    DataIn => regB,
    --    Address => aluResult,
    --    WriteEn => memW,
    --    Enable => '1',
    --    DataOut => memOut);
    
    DataMux : Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        i_Select => mem2Reg,
        CLK => fstCLK,
        RST => RST,
        i_Data1 => aluResult,
        i_Data2 => memOut,
        o_Data => regD);
    
    instructionExt(15 downto 2) <= SXT(instruction(7 downto 0), 14);
    instructionExt(1 downto 0) <= "00";
    
    AddressAdder : ALU port map(
        i_setting => "00",
        CLK => fstCLK,
        RST => RST,
        i_dataA => instructionExt,
        i_dataB => pcPlus4,
        o_data => pcALUOut);
    
    PCAdder : ALU port map(
        i_setting => "00",
        CLK => fstCLK,
        RST => RST,
        i_dataA => pcOut,
        i_dataB => "100",
        o_data => pcPlus4);
    
    PCCalcMux: Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        i_Select => branch,
        CLK => fstCLK,
        RST => RST,
        i_Data1 => pcPlus4,
        i_Data2 => pcALUOut,
        o_Data => calcPC);
    
    pcExt(15 downto 14) <= pcPlus4(15 downto 14);
    pcExt(13 downto 2) <= instruction(11 downto 0);
    pcExt(1 downto 0) <= "00";
    
    PCMux : Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        i_Select => jump,
        CLK => fstCLK,
        RST => RST,
        i_Data1 => calcPC,
        i_Data2 => pcExt,
        o_Data => pcIn);

    
    Mem: FullMemory port map(
        CLK => fstCLK,
        WE => memW,
        RST => RST,
        DataIn => RegB,
        InstAddr => pcOut,
        DataAddr => aluResult,
        InstOut => instruction,
        DataOut => memOut);
end architecture;