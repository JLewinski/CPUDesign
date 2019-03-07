entity hello_world is
end;

architecture rtl of hello_world is
begin
  stimulus : process
  begin
    assert false
      report "Hello World"
      severity note;
    wait;
  end process stimulus;
end hello_world;