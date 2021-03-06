library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity Menu is
    port (
	  clk : in std_logic;
	  valid : in std_logic;
	  row : in unsigned(9 downto 0);
	  col : in unsigned(9 downto 0);
	  cmd1 : in unsigned(3 downto 0);
	  cmd2 : in unsigned(3 downto 0);
	  selector : in std_logic;
	  rgb : out std_logic_vector(5 downto 0)
    );
end entity;

architecture synth of Menu is
component game_graphics_1v1 is
   port (
	 clk : in std_logic;
	 valid : in std_logic;
	 row : in unsigned(9 downto 0);
	 col : in unsigned(9 downto 0);
	 cmd1 : in unsigned(3 downto 0);
	 cmd2 : in unsigned(3 downto 0);
	 status: out unsigned(2 downto 0);
	 rgb : out std_logic_vector(5 downto 0)
   );
end component;

component game_graphics is
   port (
	 clk : in std_logic;
	 valid : in std_logic;
	 row : in unsigned(9 downto 0);
	 col : in unsigned(9 downto 0);
	 cmd : in unsigned(3 downto 0);
	 status: out unsigned(2 downto 0);
	 rgb : out std_logic_vector(5 downto 0)
   );
end component;

component win is
    port(
        wr_clk_i: in std_logic;
        rd_clk_i: in std_logic;
        wr_clk_en_i: in std_logic;
        rd_en_i: in std_logic;
        rd_clk_en_i: in std_logic;
        wr_en_i: in std_logic;
        wr_data_i: in std_logic_vector(31 downto 0);
        wr_addr_i: in std_logic_vector(4 downto 0);
        rd_addr_i: in std_logic_vector(4 downto 0);
        rd_data_o: out std_logic_vector(31 downto 0)
    );
end component;

component start is
    port(
        wr_clk_i: in std_logic;
        rd_clk_i: in std_logic;
        wr_clk_en_i: in std_logic;
        rd_en_i: in std_logic;
        rd_clk_en_i: in std_logic;
        wr_en_i: in std_logic;
        wr_data_i: in std_logic_vector(63 downto 0);
        wr_addr_i: in std_logic_vector(5 downto 0);
        rd_addr_i: in std_logic_vector(5 downto 0);
        rd_data_o: out std_logic_vector(63 downto 0)
    );
end component;
-- Colors
constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
constant BLACK: std_logic_vector(5 downto 0) := "000000";
constant YELLOW: std_logic_vector(5 downto 0) := "111100";
constant WHITE: std_logic_vector(5 downto 0) := "111111";
constant PINK: std_logic_vector(5 downto 0) := "110010";

constant STANBY_CMD: integer :=9;

signal state: integer := 0;
signal game: integer;
signal rgb1, rgb2: std_logic_vector(5 downto 0);
signal status: unsigned(2 downto 0);
signal is_on: std_logic;

signal player: unsigned(3 downto 0);
signal player1, player2: unsigned(3 downto 0);

-- output 32-bit words from ROM
signal read_data: std_logic_vector(31 downto 0);
signal read_data2: std_logic_vector(63 downto 0);

signal is_win: std_logic;signal is_start: std_logic;

signal start_game: std_logic;

begin
classic: game_graphics port map(clk,valid,row,col,player, rgb1);
multi: game_graphics_1v1 port map(clk,valid,row,col,player1,player2,status,rgb2);

win_screen: win port map(
    wr_clk_i=> clk,
    rd_clk_i=> clk,
    wr_clk_en_i=> '0',
    rd_en_i=> '1',
    rd_clk_en_i=> '1',
    wr_en_i=> '0',
    wr_data_i=> 32x"0",
    wr_addr_i=> 5x"0",
    rd_addr_i=> std_logic_vector(row(8 downto 4)),
    rd_data_o=> read_data
);	

start_screen: start port map(
    wr_clk_i=> clk,
    rd_clk_i=> clk,
    wr_clk_en_i=> '0',
    rd_en_i=> '1',
    rd_clk_en_i=> '1',
    wr_en_i=> '0',
    wr_data_i=> 64x"0",
    wr_addr_i=> 6x"0",
    rd_addr_i=> std_logic_vector(row(8 downto 3)),
    rd_data_o=> read_data2
);

process(clk,state) is begin
	  if rising_edge(clk)  and row = to_unsigned(500,10) and col = to_unsigned(650,10) then
		    if selector = '1' then
			      player <= cmd1;
		    elsif selector = '0' then
		        player1 <= cmd1;
			      player2 <= cmd2;
		    end if;
	   end if;
end process;

state <=  0 when selector = '0' and status= "001" else
		      1 when selector = '0' and status= "010" else
		      2 when selector = '0' and status= "011" else
		      3 when selector = '1' else
		      4 when selector = '0' and status= "000";
		  
is_win <= read_data(to_integer(5d"31" - col(7 downto 2)));
is_start <= read_data2(to_integer(6d"63" - col(9 downto 4)));

--start_game <= '1' when player = START_CMD else '0' when ();

rgb <= --WHITE when valid = '1'and is_start= '1' and status1 = '0' else
	      rgb1 when state = 3 else
	      rgb2 when state = 0 else
	      PINK when valid = '1'and is_win = '1' and state = 1 else
	      BLUE when valid = '1'and is_win = '1' and state = 2 else BLACK;
end;