`include "../../public.v"

module Decoder(opcode, rs, rt, funct, rtype, itype, btype, mtype, jtype, stype, ltype, mfttype,
		add, addu, sub, subu, sll, srl, sra, sllv, srlv, srav, and1, or1, xor1, nor1, slt, sltu,
		addi, addiu, andi, xori, lui, ori, slti, sltiu,
		bltzbgez, beq, bne, blez, bgtz, bltz, bgez,
		sw, sh, sb, lb, lbu, lh, lhu, lw,
		j, jal, jr, jalr,
		mult, multu, div, divu, mthi, mtlo, mfhi, mflo,
		cp0type,eret, mfc0, mtc0);

	input [5:0] opcode;
	input [5:0] funct;
	input [4:0] rs;
	input [4:0] rt; 

	output rtype, itype, btype, mtype, jtype, stype, ltype, mfttype;
	output add, addu, sub, subu, sll, srl, sra, sllv, srlv, srav, and1, or1, xor1, nor1, slt, sltu;
	output addi, addiu, andi, xori, lui, ori;
	output slti, sltiu;
	output bltzbgez;
	output beq, bne, blez, bgtz, bltz, bgez;
	output sw, sh, sb, lb, lbu, lh, lhu, lw;
	output j, jal, jr, jalr;
	
	output mult, multu, div, divu;
	output mthi, mtlo, mfhi, mflo;
	
	output cp0type;
	output eret, mfc0, mtc0;
	
	
	
	assign rtype = (opcode == `OP_RTYPE)? 1'b1:1'b0;
	
    assign addu = (rtype && funct == `FUNCT_ADDU) ? 1'b1:1'b0;
    assign subu = (rtype && funct == `FUNCT_SUBU) ? 1'b1:1'b0;
	assign jr = (rtype && funct == `FUNCT_JR) ? 1'b1:1'b0;
	
	assign add = (rtype && funct == `FUNCT_ADD) ? 1'b1:1'b0;
    assign sub = (rtype && funct == `FUNCT_SUB) ? 1'b1:1'b0;
	assign and1 = (rtype && funct == `FUNCT_AND) ? 1'b1:1'b0;
	assign sll = (rtype && funct == `FUNCT_SLL) ? 1'b1:1'b0;
	assign srl = (rtype && funct == `FUNCT_SRL) ? 1'b1:1'b0;
	assign sra = (rtype && funct == `FUNCT_SRA) ? 1'b1:1'b0;
    assign sllv = (rtype && funct == `FUNCT_SLLV) ? 1'b1:1'b0;
	assign srlv = (rtype && funct == `FUNCT_SRLV) ? 1'b1:1'b0;
	assign srav = (rtype && funct == `FUNCT_SRAV) ? 1'b1:1'b0;
    assign and1 = (rtype && funct == `FUNCT_AND) ? 1'b1:1'b0;
	assign or1 = (rtype && funct == `FUNCT_OR) ? 1'b1:1'b0;
    assign xor1 = (rtype && funct == `FUNCT_XOR) ? 1'b1:1'b0;
	assign nor1 = (rtype && funct == `FUNCT_NOR) ? 1'b1:1'b0;
	assign jalr = (rtype && funct == `FUNCT_JALR) ? 1'b1:1'b0;
	assign slt = (rtype && funct == `FUNCT_SLT) ? 1'b1:1'b0;
	assign sltu = (rtype && funct == `FUNCT_SLTU) ? 1'b1:1'b0;
	
	assign addi = (opcode == `OP_ADDI) ? 1'b1:1'b0;
	assign addiu = (opcode == `OP_ADDIU) ? 1'b1:1'b0;
	assign andi = (opcode == `OP_ANDI) ? 1'b1:1'b0;
	assign xori = (opcode == `OP_XORI) ? 1'b1:1'b0;
	
	assign slti = (opcode == `OP_SLTI) ? 1'b1:1'b0;
	assign sltiu = (opcode == `OP_SLTIU) ? 1'b1:1'b0;
	
	assign bltzbgez = (opcode == `OP_BLTZBGEZ) ? 1'b1:1'b0;
	assign bltz = (bltzbgez && rt == `RT_BLTZ) ? 1'b1:1'b0;
	assign bgez = (bltzbgez && rt == `RT_BGEZ) ? 1'b1:1'b0;
	
	assign bne = (opcode == `OP_BNE) ? 1'b1:1'b0;
	assign blez = (opcode == `OP_BLEZ) ? 1'b1:1'b0;
	assign bgtz = (opcode == `OP_BGTZ) ? 1'b1:1'b0;
	
    assign lw = (opcode == `OP_LW) ? 1'b1:1'b0;
	assign sw = (opcode == `OP_SW) ? 1'b1:1'b0;
	assign beq = (opcode == `OP_BEQ) ? 1'b1:1'b0;
	assign lui = (opcode == `OP_LUI) ? 1'b1:1'b0;
	assign ori = (opcode == `OP_ORI) ? 1'b1:1'b0;
	assign j = (opcode == `OP_J) ? 1'b1:1'b0;
	assign jal = (opcode == `OP_JAL) ? 1'b1:1'b0;
	
	assign sb = (opcode == `OP_SB) ? 1'b1:1'b0;
	assign sh = (opcode == `OP_SH) ? 1'b1:1'b0;
	assign lb = (opcode == `OP_LB) ? 1'b1:1'b0;
	assign lbu = (opcode == `OP_LBU) ? 1'b1:1'b0;
	assign lh = (opcode == `OP_LH) ? 1'b1:1'b0;
	assign lhu = (opcode == `OP_LHU) ? 1'b1:1'b0;
	
	assign cp0type = (opcode == `OP_CP0) ? 1'b1:1'b0;
	
	assign eret = (cp0type && rs == `RS_ERET) ? 1'b1:1'b0;
	assign mfc0 = (cp0type && rs == `RS_MFC0) ? 1'b1:1'b0;
	assign mtc0 = (cp0type && rs == `RS_MTCO) ? 1'b1:1'b0;
	
	assign mult = (rtype && funct == `FUNCT_MULT) ? 1'b1:1'b0;
	assign multu = (rtype && funct == `FUNCT_MULTU) ? 1'b1:1'b0;
	assign div = (rtype && funct == `FUNCT_DIV) ? 1'b1:1'b0;
	assign divu = (rtype && funct == `FUNCT_DIVU) ? 1'b1:1'b0;
	assign mthi = (rtype && funct == `FUNCT_MTHI) ? 1'b1:1'b0;
	assign mtlo = (rtype && funct == `FUNCT_MTLO) ? 1'b1:1'b0;
	assign mfhi = (rtype && funct == `FUNCT_MFHI) ? 1'b1:1'b0;
	assign mflo = (rtype && funct == `FUNCT_MFLO) ? 1'b1:1'b0;
	
	
	assign itype = (addi || addiu || andi || xori || lui || ori || slti || sltiu) ? 1'b1:1'b0;
	assign btype = (beq || bne || blez || bgtz || bltz || bgez) ? 1'b1:1'b0;
	assign mtype = (sw || sh || sb || lb || lbu || lh || lhu || lw) ? 1'b1:1'b0;
	assign jtype = (j || jal || jalr || jr) ? 1'b1:1'b0;
	assign stype = (sw || sh || sb) ? 1'b1:1'b0;
	assign ltype = (lb || lbu || lh || lhu || lw) ? 1'b1:1'b0;
	assign mfttype = (mult || multu || div || divu || mfhi || mflo || mthi || mtlo || mfc0 || mtc0)? 1'b1:1'b0;
	
		
endmodule