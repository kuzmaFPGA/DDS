library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dds_top is
  port (
    clk_50MHz   : in  std_logic;               -- 50 MHz clock
    rst_btn     : in  std_logic;               -- Reset button
    freq_up_btn : in  std_logic;               -- Frequency up button
    freq_down_btn : in  std_logic;             -- Frequency down button
    shift_up_btn : in  std_logic;               -- Frequency up button
    shift_down_btn : in  std_logic;             -- Frequency down button
    dac_clk     : out std_logic;               -- DAC clock
    dac_data    : out std_logic_vector(13 downto 0); -- DAC data
--    led_1       : out std_logic;              -- LED for 2 points
    led_2       : out std_logic;               -- LED for 4 points
    led_3       : out std_logic;              -- LED for 2 points
--    led_4       : out std_logic;              -- LED for 4 points
    led_5       : out std_logic;              -- LED for 2 points
    led_6       : out std_logic               -- LED for 4 points
  );
end dds_top;

architecture Behavioral of dds_top is

  constant FTW_WIDTH      : integer := 32;
  constant PHASE_WIDTH    : integer := 12;
  constant SHIFT_WIDTH    : integer := 8;
  constant AMPL_WIDTH     : integer := 14;

  signal ftw       : std_logic_vector(FTW_WIDTH-1 downto 0);
  signal ampl      : std_logic_vector(AMPL_WIDTH-1 downto 0);
  signal phase_out : std_logic_vector(PHASE_WIDTH-1 downto 0);

  signal ftw_value : unsigned(FTW_WIDTH-1 downto 0) := to_unsigned(8590, FTW_WIDTH); -- Initial FTW

  signal up_btn_debounced, down_btn_debounced : std_logic;
  signal up_btn_prev   : std_logic := '0';
  signal down_btn_prev : std_logic := '0';
  signal up_btn_edge   : std_logic := '0';
  signal down_btn_edge : std_logic := '0';

  signal shift_up_btn_debounced, shift_down_btn_debounced : std_logic;
  signal shift_up_btn_prev   : std_logic := '0';
  signal shift_down_btn_prev : std_logic := '0';
  signal shift_up_btn_edge   : std_logic := '0';
  signal shift_down_btn_edge : std_logic := '0';
  
  signal lut_step_shift       : std_logic_vector(SHIFT_WIDTH-1 downto 0);
  signal lut_step_shift_value : unsigned(SHIFT_WIDTH-1 downto 0) := to_unsigned(0, SHIFT_WIDTH); -- LUT step (initial 0)

begin

  -- DDS instance
  dds_inst: entity work.dds_synthesizer
    generic map(
    ftw_width => FTW_WIDTH,
    phase_width => PHASE_WIDTH,
    ampl_width => AMPL_WIDTH,
    shift_width => SHIFT_WIDTH
    )
    port map(
      clk_i   => clk_50MHz,
      rst_i   => rst_btn,
      ftw_i   => ftw,
      phase_i => (others => '0'),
      phase_o => phase_out,
      lut_step_shift_i => lut_step_shift, -- Передаємо зсув кроку LUT
      ampl_o  => ampl
    );

  -- Frequency tuning word
  ftw <= std_logic_vector(ftw_value);

  lut_step_shift <= std_logic_vector(lut_step_shift_value);
  
  -- Detect button edges and change FTW
  process(clk_50MHz, rst_btn)
  begin
    if rst_btn = '1' then
      ftw_value <= to_unsigned(8590, FTW_WIDTH); -- Reset FTW to initial value
      
      up_btn_prev   <= '0';
      down_btn_prev <= '0';
      up_btn_edge   <= '0';
      down_btn_edge <= '0';
      
      shift_up_btn_prev <= '0';
      shift_down_btn_prev <= '0';
      shift_up_btn_edge <= '0';
      shift_down_btn_edge <= '0';
      
      lut_step_shift_value <= to_unsigned(0, SHIFT_WIDTH); -- Reset LUT step
      --led_1 <= '0'; -- За замовчуванням
      --led_2 <= '0';
    elsif rising_edge(clk_50MHz) and rst_btn = '0' then
      --led_1 <= shift_up_btn_debounced;--'0';
      --led_2 <= shift_down_btn_debounced;--'0';
      -- Edge detection for buttons
      up_btn_edge   <= up_btn_debounced and not up_btn_prev;
      down_btn_edge <= down_btn_debounced and not down_btn_prev;
      
      shift_up_btn_edge   <= shift_up_btn_debounced and not shift_up_btn_prev;
      shift_down_btn_edge <= shift_down_btn_debounced and not shift_down_btn_prev;

      -- Update previous button states
      up_btn_prev   <= up_btn_debounced;
      down_btn_prev <= down_btn_debounced;
      shift_up_btn_prev   <= shift_up_btn_debounced;
      shift_down_btn_prev <= shift_down_btn_debounced;
      
      -- Frequency adjustment
      if up_btn_edge = '1' then
        ftw_value <= ftw_value + to_unsigned(86, FTW_WIDTH); -- Step +1 Hz
      elsif down_btn_edge = '1' then
        ftw_value <= ftw_value - to_unsigned(86, FTW_WIDTH); -- Step -1 Hz
      end if;

      if shift_up_btn_edge = '1' then
        if lut_step_shift_value < to_unsigned(255, SHIFT_WIDTH) then -- Верхня межа
            lut_step_shift_value <= lut_step_shift_value + 1; 
        end if;
        elsif shift_down_btn_edge = '1' then
        if lut_step_shift_value > to_unsigned(0, SHIFT_WIDTH) then -- Нижня межа
            lut_step_shift_value <= lut_step_shift_value - 1;
            end if;
      end if;
--    case lut_step_shift_value is
--      when to_unsigned(0, SHIFT_WIDTH) =>
--        led_1 <= '0';
--        led_2 <= '0';
--      when to_unsigned(1, SHIFT_WIDTH) =>
--        led_1 <= '1';
--        led_2 <= '0';
--      when to_unsigned(2, SHIFT_WIDTH) =>
--        led_1 <= '0';
--        led_2 <= '1';
----      when to_unsigned(3, SHIFT_WIDTH) =>
----        led_1 <= '1';
----        led_2 <= '1';
--      when others =>
--        led_1 <= '1'; -- За замовчуванням
--        led_2 <= '1';
--    end case;      
    end if;
  end process;

  -- Debounce logic for up button
  --debounce_up: 
  process(clk_50MHz)
    variable counter : integer;
  begin
    if rising_edge(clk_50MHz) then
      if freq_up_btn = '1' then
        counter := counter + 1;
        if counter > 10000 then
          up_btn_debounced <= '1';
        end if;
      else
        counter := 0;
        up_btn_debounced <= '0';
      end if;
    end if;
  end process;

  -- Debounce logic for down button
  --debounce_down: 
  process(clk_50MHz)
    variable counter : integer;
  begin
    if rising_edge(clk_50MHz) then
      if freq_down_btn = '1' then
        counter := counter + 1;
        if counter > 10000 then
          down_btn_debounced <= '1';
        end if;
      else
        counter := 0;
        down_btn_debounced <= '0';
      end if;
    end if;
  end process;

  -- Debounce logic for up button
  process(clk_50MHz)
    variable counter : integer;
  begin
    if rising_edge(clk_50MHz) then
      if shift_up_btn = '1' then
        counter := counter + 1;
        if counter > 10000 then
          shift_up_btn_debounced <= '1';
        end if;
      else
        counter := 0;
        shift_up_btn_debounced <= '0';
      end if;
    end if;
  end process;

  -- Debounce logic for down button
  process(clk_50MHz)
    variable counter : integer;
  begin
    if rising_edge(clk_50MHz) then
      if shift_down_btn = '1' then
        counter := counter + 1;
        if counter > 10000 then
          shift_down_btn_debounced <= '1';
        end if;
      else
        counter := 0;
        shift_down_btn_debounced <= '0';
      end if;
    end if;
  end process;
  
  -- DAC outputs
  dac_clk <= clk_50MHz;
  dac_data <= ampl;
  
  led_2 <= up_btn_debounced;  --SW1
  led_3 <= down_btn_debounced; --SW2
  led_5 <= shift_up_btn_debounced; --SW3
  led_6 <= shift_down_btn_debounced; --SW4
  
end Behavioral;
