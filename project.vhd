-------------------------------------------------------------------------------------------
-- Progetto Reti Logiche
-- Melanie Tonarelli 10787497
-- Niccolo' Sobrero 10718675
-------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- interfaccia del componente
entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_w : in std_logic;
o_z0 : out std_logic_vector(7 downto 0);
o_z1 : out std_logic_vector(7 downto 0);
o_z2 : out std_logic_vector(7 downto 0);
o_z3 : out std_logic_vector(7 downto 0);
o_done : out std_logic;
o_mem_addr : out std_logic_vector(15 downto 0);
i_mem_data : in std_logic_vector(7 downto 0);
o_mem_we : out std_logic;
o_mem_en : out std_logic
);
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is
    type state_type is ( IDLE, GET_REG, GET_MEM, WRITE_REG, WAIT_RAM, DONE_STATE );
    signal current_state, next_state : state_type;
    signal o_done_next : std_logic;
    signal o_z0_next, o_z1_next, o_z2_next, o_z3_next : std_logic_vector(7 downto 0);
    signal mem_address, mem_address_next : std_logic_vector(15 downto 0);
    signal ch1_address, ch1_address_next : std_logic;
    signal ch0_address, ch0_address_next : std_logic;
    signal reg0, reg1, reg2, reg3 : std_logic_vector (7 downto 0); 
    signal reg0_next, reg1_next, reg2_next, reg3_next : std_logic_vector (7 downto 0);
    
begin 

    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            current_state <= IDLE;
            mem_address <= (others => '0');
            ch1_address <= '0';
            ch0_address <= '0';
            reg0 <= "00000000";
            reg1 <= "00000000";
            reg2 <= "00000000";
            reg3 <= "00000000";
	        o_done <= '0';
	        o_z0 <= (others => '0');
	        o_z1 <= (others => '0');
	        o_z2 <= (others => '0');
	        o_z3 <= (others => '0');
        elsif rising_edge(i_clk) then
            current_state <= next_state;
            mem_address <= mem_address_next;
            ch1_address <= ch1_address_next;
            ch0_address <= ch0_address_next;
            reg0 <= reg0_next;
            reg1 <= reg1_next;
            reg2 <= reg2_next;
            reg3 <= reg3_next;
	        o_done <= o_done_next;
	        o_z0 <= o_z0_next;
	        o_z1 <= o_z1_next;
	        o_z2 <= o_z2_next;
	        o_z3 <= o_z3_next;
        end if;
    end process;
    
    
    process ( current_state, i_start, i_w, i_mem_data, ch1_address, ch0_address, reg0, reg1, reg2, reg3, mem_address )
    begin
        case current_state is
            when IDLE =>
                reg0_next <= reg0;
                reg1_next <= reg1;
                reg2_next <= reg2;
                reg3_next <= reg3;
                mem_address_next <= "0000000000000000";
                if i_start = '0' then
                    ch1_address_next <= '0';
                    ch0_address_next <= '0';
                    next_state <= IDLE;
                else 
                    ch1_address_next <= i_w;
                    ch0_address_next <= '0';
                    next_state <= GET_REG;
                end if;
             
            when GET_REG =>
                ch1_address_next <= ch1_address;
                ch0_address_next <= i_w;
                reg0_next <= reg0;
                reg1_next <= reg1;
                reg2_next <= reg2;
                reg3_next <= reg3;
                mem_address_next <= (others => '0');
                next_state <= GET_MEM;
            
            when GET_MEM =>
                ch1_address_next <= ch1_address;
                ch0_address_next <= ch0_address;
                reg0_next <= reg0;
                reg1_next <= reg1;
                reg2_next <= reg2;
                reg3_next <= reg3;
                 if i_start = '1' then
                    mem_address_next <= mem_address(14 downto 0) & i_w;
                    next_state <= GET_MEM;
                 else
                    mem_address_next <= mem_address;
                    next_state <= WAIT_RAM;
                 end if;
                 
            when WAIT_RAM =>
                next_state <= WRITE_REG;
                mem_address_next <= mem_address;
                ch1_address_next <= ch1_address;
                ch0_address_next <= ch0_address;
                reg0_next <= reg0;
                reg1_next <= reg1;
                reg2_next <= reg2;
                reg3_next <= reg3;
                
            when WRITE_REG =>
                mem_address_next <= mem_address;
                ch1_address_next <= ch1_address;
                ch0_address_next <= ch0_address;
                if ch1_address = '0' and ch0_address = '0' then
                    reg0_next <= i_mem_data;
                    reg1_next <= reg1;
                    reg2_next <= reg2;
                    reg3_next <= reg3;
                elsif ch1_address = '0' and ch0_address = '1' then
                    reg0_next <= reg0;
                    reg1_next <= i_mem_data;
                    reg2_next <= reg2;
                    reg3_next <= reg3;
                elsif ch1_address = '1' and ch0_address = '0' then
                    reg0_next <= reg0;
                    reg1_next <= reg1;
                    reg2_next <= i_mem_data;
                    reg3_next <= reg3;
                elsif ch1_address = '1' and ch0_address = '1' then 
                    reg0_next <= reg0;
                    reg1_next <= reg1;
                    reg2_next <= reg2;
                    reg3_next <= i_mem_data;
                end if;
                next_state <= DONE_STATE; -- next_state <= IDLE;
                
             when others =>			
                reg0_next <= reg0;
                reg1_next <= reg1;
                reg2_next <= reg2;
                reg3_next <= reg3;
                ch1_address_next <= '0';    
                ch0_address_next <= '0'; 
                mem_address_next <= (others => '0');  
                next_state <= IDLE;           
            
             
        end case;
    end process;
    
    
    process ( current_state, i_start, i_w, i_mem_data, ch1_address, ch0_address, reg0, reg1, reg2, reg3, mem_address )
    begin
        case current_state is
           when IDLE => 
                o_z0_next <= "00000000";
                o_z1_next <= "00000000";
                o_z2_next <= "00000000";
                o_z3_next <= "00000000";
                o_done_next <= '0';
                
           when GET_REG =>
                o_z0_next <= "00000000";
                o_z1_next <= "00000000";
                o_z2_next <= "00000000";
                o_z3_next <= "00000000";
                o_done_next <= '0';
                
            when GET_MEM =>
                  o_z0_next <= "00000000";
                  o_z1_next <= "00000000";
                  o_z2_next <= "00000000";
                  o_z3_next <= "00000000";
                  o_done_next <= '0';
                  
           when WAIT_RAM =>
                o_z0_next <= "00000000";
                o_z1_next <= "00000000";
                o_z2_next <= "00000000";
                o_z3_next <= "00000000";
                o_done_next <= '0';
                 
           when WRITE_REG =>
	            o_z0_next <= "00000000";
                o_z1_next <= "00000000";
                o_z2_next <= "00000000";
                o_z3_next <= "00000000";
                o_done_next <= '0'; 
                
           when others =>	
               o_z0_next <= reg0;
               o_z1_next <= reg1;
               o_z2_next <= reg2;
               o_z3_next <= reg3;
               o_done_next <= '1';
               
        end case;
    end process;
    
    o_mem_we <= '0';
    o_mem_en <= '1';
    o_mem_addr <= mem_address;
end Behavioral;
