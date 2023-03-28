----------------------------------------------------------------------------------
-- Dawid Walczak
-- 255643
-- 15.05.2022r
-- PROJEKT WSC
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;
use IEEE.STD_LOGIC_textio.all;
USE ieee.numeric_std.ALL;
entity dystrybutor is

	port(
		  clk : in std_logic;
		  clk_pompa: in std_logic;
		  reset : in std_logic; 
		  
		  czuj_paliwa: in std_logic_vector(7 downto 0):="00000000";
		  paliwo: in std_logic_vector(1 downto 0):="00"; -- "01" - LPG; "10"- benzyna; "11" Diesel; "00" nie wybrano;
		  koszty: out std_logic_vector(7 downto 0); -- wyjœcie z którego bêdê odczytywa³ za ile zatankowa³em i zapisywa³ tê liczbê do pliku
		  litry: out std_logic_vector(7 downto 0); -- wyjœcie z którego bêdê odczytywa³ ile litrów zatankowa³em i zapisywa³ tê liczbê do pliku
		  postep		: out std_logic; -- tankowanie skonczone
		  
		  --verilog
		  data_out: out std_logic_vector(1 downto 0); 
		  licznik_koszty1 :out std_logic_vector(7 downto 0);
		  clockEn1: out std_logic:='0';
		  licznik_litry1	: out std_logic_vector(7 downto 0)
		  );  

end entity dystrybutor;

architecture dystrybutor_arch of dystrybutor is

	type STANY is (czuwanie, rodz_paliwa , tankowanie , wydruk); -- fsm dystrybutora
	signal stan, stan_nast: STANY; 
	signal licznik_litry: std_logic_vector(7 downto 0); -- sygnal licznika zliczajacego ilosc zatankowanego paliwa
	signal licznik_koszty: std_logic_vector(7 downto 0); -- sygnal licznika zliczajacego kwote tankowania
	signal postep1: std_logic;
	signal clockEn: std_logic;
	
begin
	
	reg:process(clk,reset) 
		begin 
			if (reset='0') then
				stan <= czuwanie;
			elsif (clk'event and clk='1') then
				stan<=stan_nast;
			end if;
		end process reg;
		
	komb_proc:process (stan,paliwo,reset,postep1,czuj_paliwa,licznik_litry) 
		begin
			stan_nast<=stan;
			
			case stan is
				when czuwanie =>
					if (reset='1') then 
						stan_nast<= rodz_paliwa;
						
					end if;
					
				when rodz_paliwa=> 
					if (reset='1') then
							if (paliwo /= "00") then 
								stan_nast<=tankowanie;
								
							else
								stan_nast<= rodz_paliwa; -- nie podano odpowiedniego paliwa
								
							end if;
					else
						stan_nast<=czuwanie;
						
					end if;
					
				when tankowanie => 
					if (reset='1') then
						if (licznik_litry=czuj_paliwa) then
							stan_nast<=wydruk;
							clockEn<='0';
							
						elsif (licznik_litry/=czuj_paliwa) then
							stan_nast<=tankowanie;
							clockEn<='1';
							
						end if;
					else
						stan_nast<=czuwanie;
						
					end if;
				
				when wydruk=>
					if (postep1='0') then
						stan_nast<=czuwanie;
						
					end if;	
				
		end case;
	end process komb_proc;
	
	licznik_proc:process(clk,reset,stan,paliwo,clockEn,czuj_paliwa,clk_pompa) -- zliczanie ilosc paliwa oraz kosztow
		begin
			if (reset='0') then 
				licznik_koszty<= (others => '0');
				licznik_litry<= (others => '0');
			elsif (clk_pompa'event and clk_pompa='1') then -- 1 takt zegara tankuje 1 litr paliwa i dolicza odpowiednia kwote za wybrany rodzaj paliwa
					if (stan=tankowanie and clockEn='1') then
						if (paliwo="10") then -- benzyna - 4 zl/litr 
							licznik_litry<=licznik_litry+1;
							licznik_koszty<=licznik_koszty+4;
						
							
						elsif (paliwo="01") then -- LPG - 2 zl/litr
							licznik_litry<=licznik_litry+1;
							licznik_koszty<=licznik_koszty+2;
							
							
						elsif (paliwo="11") then --diesel - 6 zl/litr
							licznik_litry<=licznik_litry+1;
							licznik_koszty<=licznik_koszty+6;
							
						else
							licznik_litry <="00000000"; 
							licznik_koszty<="00000000"; 
					
						end if;
					else
						licznik_litry<=(others=>'0');   
						licznik_koszty<=(others=>'0');
						
					end if;
			end if;
		end process licznik_proc;
			
		postep1 <= '1' when czuj_paliwa=licznik_litry and stan=wydruk else '0';
		litry <= licznik_litry when postep1='1' else "00000000";
		postep<=postep1 when postep1='1' else '0';
		koszty <= licznik_koszty when postep1='1' else "00000000" ;  
		licznik_litry1<=licznik_litry;
		licznik_koszty1<=licznik_koszty;
		data_out<="00" when stan=czuwanie	
		else "01" when stan=rodz_paliwa
		else "10" when stan=tankowanie
		else "11" when stan=wydruk;
		clockEn1<='1' when stan=tankowanie else '0';
					
end dystrybutor_arch;

