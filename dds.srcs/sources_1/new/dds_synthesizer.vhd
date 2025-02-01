-- Підключення бібліотек IEEE та користувацького пакету
library ieee;
use ieee.std_logic_1164.all;  -- Для роботи зі стандартною логікою
use ieee.numeric_std.all;
use work.sine_lut_pkg.all;    -- Підключення користувацького пакету з таблицею синусоїд

-- Опис пакету для DDS-синтезатора
package dds_synthesizer_pkg is
  -- Оголошення компоненту DDS-синтезатора
  component dds_synthesizer
    generic(
      ftw_width : integer;   -- Ширина слова частотного слова (FTW)
      phase_width : integer; -- Додаємо PHASE_WIDTH
      ampl_width : integer;  -- Додаємо AMPL_WIDTH
      shift_width : integer   -- Додаємо SHIFT_WIDTH
    );
    port(
      clk_i   : in  std_logic; -- Вхідний сигнал тактування
      rst_i   : in  std_logic; -- Сигнал скидання
      ftw_i   : in  std_logic_vector(ftw_width-1 downto 0); -- Вхідне частотне слово
      phase_i : in  std_logic_vector(phase_width-1 downto 0); -- Вхідний фазовий зсув
      phase_o : out std_logic_vector(phase_width-1 downto 0); -- Вихідний фазовий зсув
      ampl_o  : out std_logic_vector(ampl_width-1 downto 0);  -- Вихідний сигнал амплітуди
      lut_step_shift_i :  in std_logic_vector(shift_width-1 downto 0)
    );
  end component;
end dds_synthesizer_pkg;

-- Тіло пакету (порожнє, оскільки немає додаткових визначень)
package body dds_synthesizer_pkg is
end dds_synthesizer_pkg;

library ieee;
use ieee.std_logic_1164.all;  -- Для роботи зі стандартною логікою
use ieee.numeric_std.all;
use work.sine_lut_pkg.all;    -- Підключення користувацького пакету з таблицею синусоїд

-- Опис сутності DDS-синтезатора
entity dds_synthesizer is
  generic(
      ftw_width : integer;   -- Ширина слова частотного слова (FTW)
      phase_width : integer; -- Додаємо PHASE_WIDTH
      ampl_width : integer;  -- Додаємо AMPL_WIDTH
      shift_width : integer   -- Додаємо SHIFT_WIDTH
  );
  port(
    clk_i   : in  std_logic; -- Вхідний сигнал тактування
    rst_i   : in  std_logic; -- Сигнал скидання
    ftw_i   : in  std_logic_vector(ftw_width-1 downto 0); -- Частотне слово
    phase_i : in  std_logic_vector(phase_width-1 downto 0); -- Фазовий зсув
    phase_o : out std_logic_vector(phase_width-1 downto 0); -- Вихідний фазовий зсув
    ampl_o  : out std_logic_vector(ampl_width-1 downto 0);  -- Вихідна амплітуда
    lut_step_shift_i : in std_logic_vector(shift_width-1 downto 0)      -- Крок LUT
  );
end dds_synthesizer;

-- Архітектура DDS-синтезатора
architecture dds_synthesizer_arch of dds_synthesizer is

  -- Сигнали для внутрішніх розрахунків
  signal ftw_accu               : std_logic_vector(ftw_width-1 downto 0); -- Акумулятор FTW
  signal phase                  : std_logic_vector(phase_width-1 downto 0); -- Текуща фаза
  signal lut_in                 : std_logic_vector(phase_width-3 downto 0); -- Вхід в LUT (таблицю синусоїд)
  signal lut_out                : std_logic_vector(ampl_width-1 downto 0); -- Вихід з LUT
  signal lut_out_delay          : std_logic_vector(ampl_width-1 downto 0); -- Затримка LUT виходу
  signal lut_out_inv_delay      : std_logic_vector(ampl_width-1 downto 0); -- Інверсія LUT виходу
  signal quadrant_2_or_4        : std_logic; -- Ознака другого чи четвертого квадранта
  signal quadrant_3_or_4        : std_logic; -- Ознака третього чи четвертого квадранта
  signal quadrant_3_or_4_delay  : std_logic; -- Затримка ознаки третього чи четвертого квадранта
  signal quadrant_3_or_4_2delay : std_logic; -- Подвійна затримка ознаки третього чи четвертого квадранта
  
  signal temp_shifted : std_ulogic_vector(phase_width-3 downto 0);
begin
  -- Вихідна фаза передається на phase_o
  phase_o         <= phase;

  -- Обчислення квадрантів
  quadrant_2_or_4 <= phase(phase_width-2); -- Другий або четвертий квадрант
  quadrant_3_or_4 <= phase(phase_width-1); -- Третій або четвертий квадрант

  temp_shifted <= std_ulogic_vector(shift_left(unsigned(phase(PHASE_WIDTH-3 downto 0)),to_integer(unsigned(lut_step_shift_i))));
  -- Генерація вхідного сигналу для таблиці синусоїд
  lut_in <= std_logic_vector(temp_shifted) when quadrant_2_or_4 = '0'
           else
           std_logic_vector(to_unsigned(2**(PHASE_WIDTH-2) - to_integer(unsigned(temp_shifted)), PHASE_WIDTH-2));
  -- Вибір вихідного сигналу амплітуди
  ampl_o <= lut_out_delay when quadrant_3_or_4_2delay = '0' else lut_out_inv_delay;

  -- Основний процес DDS
  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      -- Ініціалізація сигналів при скиданні
      ftw_accu <= (others => '0');
      phase  <= (others => '0');
      lut_out <= (others => '0');
      lut_out_delay <= (others => '0');
      lut_out_inv_delay <= (others => '0');
      quadrant_3_or_4_delay <= '0';
      quadrant_3_or_4_2delay <= '0';
    elsif clk_i'event and clk_i = '1' then
      -- Оновлення акумулятора FTW
      ftw_accu <= std_logic_vector(unsigned(ftw_accu) + unsigned(ftw_i));
      -- Обчислення поточної фази
      phase <= std_logic_vector(unsigned(ftw_accu(ftw_width-1 downto ftw_width-PHASE_WIDTH)) + unsigned(phase_i));
      -- Генерація сигналу на основі квадранта
      if quadrant_2_or_4 = '1' and phase(phase_width - 3 downto 0) = std_logic_vector (to_unsigned(0, phase_width - 2)) then
        lut_out <= std_logic_vector(to_unsigned(2**(ampl_width - 1) - 1 +8191, ampl_width));

      else
        lut_out <= std_logic_vector(to_unsigned(to_integer(unsigned(sine_lut(to_integer(unsigned(lut_in))))) + 8191, ampl_width));
      end if;

      -- Оновлення затримок і інверсій
      quadrant_3_or_4_delay <= quadrant_3_or_4;
      quadrant_3_or_4_2delay <= quadrant_3_or_4_delay;
      lut_out_inv_delay <= std_logic_vector(to_unsigned(-1 * to_integer(unsigned(lut_out)), ampl_width));
      lut_out_delay <= lut_out;
    end if;
  end process;
  
end dds_synthesizer_arch; -- Завершення архітектури