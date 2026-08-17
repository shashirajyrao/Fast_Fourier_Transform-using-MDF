module MDF_twiddle_rom
(
    input  [9:0] addr,

    output reg [15:0] twiddle_real,
    output reg [15:0] twiddle_imag
);


reg [31:0] rom_mem [0:511];

reg [31:0] temp;


initial
begin
    $readmemh("twiddles.mem",rom_mem);
end


always @(*)
begin

    if(addr < 512)
    begin
        twiddle_real = rom_mem[addr][31:16];
        twiddle_imag = rom_mem[addr][15:0];
    end

    else
    begin
        temp = rom_mem[addr-512];

        twiddle_real = (~temp[31:16]) + 16'd1;
        twiddle_imag = (~temp[15:0])  + 16'd1;

    end

end

endmodule