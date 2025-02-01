library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.dds_synthesizer_pkg.all;
use work.sine_lut_pkg.all;

entity dds_synthesizer_tb is
  generic(
    clk_period : time := 10 ns;
    ftw_width : integer := 32;
    phase_width : integer := 12; -- Додано phase_width
    ampl_width : integer := 14; -- Додано ampl_width
    shift_width : integer := 8  -- Додано shift_width
  );
end dds_synthesizer_tb;

architecture dds_synthesizer_tb_arch of dds_synthesizer_tb is

  signal clk,rst : std_logic := '0';
  signal ftw : std_logic_vector(ftw_width-1 downto 0);
  signal init_phase : std_logic_vector(phase_width-1 downto 0);
  signal phase_out : std_logic_vector(phase_width-1 downto 0);
  signal ampl_out : std_logic_vector(ampl_width-1 downto 0);
  signal lut_step_shift : std_logic_vector(shift_width-1 downto 0) := (others => '0'); -- Додано lut_step_shift

begin

  -- Інстанціація DDS
  dds_synth: entity work.dds_synthesizer
    generic map(
      ftw_width   => ftw_width,
      phase_width => phase_width,
      ampl_width  => ampl_width,
      shift_width => shift_width
    )
    port map(
      clk_i           => clk,
      rst_i           => rst,
      ftw_i           => ftw,
      phase_i         => init_phase,
      phase_o         => phase_out,
      ampl_o          => ampl_out,
      lut_step_shift_i => lut_step_shift -- Підключено lut_step_shift
    );

  -- Початкові умови
  init_phase <= (others => '0');
  ftw <= conv_std_logic_vector(2147483, ftw_width); -- 20us period @ 100MHz, ftw_width=32
end dds_synthesizer_tb_arch;