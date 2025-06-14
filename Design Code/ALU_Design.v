
`include "define.v"

module ALU_design #(parameter Width = 8 ,cmd_len = 4)(OPA,OPB,INP_VALID,CIN,CLK,RST,CMD,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);

//Input output port declaration
  input [Width-1:0] OPA;
  input [Width-1:0] OPB;
  input CLK,RST,CE,MODE,CIN;
  input [1:0] INP_VALID;
  input [cmd_len -1:0] CMD;
  output reg [(2*Width)-1:0] RES;
  output reg COUT;
  output reg OFLOW;
  output reg G;
  output reg E;
  output reg L;
  output reg ERR;

//temp variables
  reg [Width-1:0] opa_t;
  reg [Width-1:0] opb_t;
  reg cin_t;
  reg [cmd_len -1:0] cmd_t;
  reg [1:0] inp_valid_t;
  reg mode_t,ce_t;
  
// Temporary internal variables for outputs
  reg [(2*Width)-1:0] res_t;
  reg cout_t;
  reg oflow_t;
  reg g_t;
  reg e_t;
  reg l_t;
  reg err_t;
 

//Rotating value register declaration
  localparam shift_bits = $clog2(Width);
  reg [shift_bits-1:0]shift_val; 
  
// For multiplication delay
  reg [(2*Width)-1:0] MUL_RES;

  
  always @(posedge CLK or posedge RST) begin
  if (RST) begin
    opa_t <= 0;
    opb_t <= 0;
    cin_t <= 0;
    mode_t <= 0;
    ce_t <= 0;
    cmd_t <= 0;
    inp_valid_t <= 0;
    
    
  end else begin
    opa_t <= OPA;
    opb_t <= OPB;
    cin_t <= CIN;
    mode_t <= MODE;
    ce_t <= CE;
    cmd_t <= CMD;
    inp_valid_t <= INP_VALID;
  end
end
          
         
  
  always@(*) begin
 
      res_t = 0;
      cout_t = 0;
      oflow_t = 0;
      g_t = 0;
      e_t = 0;
      l_t = 0;
      err_t = 0; 
     
       
      if(ce_t)                           
         begin
          if(mode_t)begin
           case(inp_valid_t)
           
                2'b11:  //A & B
                begin
                      case(cmd_t)              //CMD is the binary code value of the Arithmetic Operation
                       `ADD:              //CMD = 0000: ADD 
                        begin 
                        res_t = opa_t + opb_t;
                        cout_t = res_t[Width];
                        end
                
                       `SUB:              //CMD = 0001: SUB
                        begin 
                        res_t = opa_t - opb_t;
                        oflow_t = res_t[Width];
                        end
                        
                       `ADD_CIN:              //CMD = 0010: ADD_cin_r
                        begin
                        res_t = opa_t + opb_t + cin_t;
                        cout_t = res_t[Width];
                        end
                
                       `SUB_CIN:             //CMD = 0011: SUB_cin_r. Here we set the overflow flag
                        begin
                        res_t = opa_t - opb_t - cin_t;
                        oflow_t = res_t[Width];
                        end
                        
                       `CMP:            //CMD = 1000: CMP
                        begin
                        res_t = 'b0;
                        if(opa_t == opb_t)
                         begin
                           e_t = 1'b1;
                           g_t = 1'b0;
                           l_t = 1'b0;
                         end
                        else if(opa_t > opb_t)
                         begin
                           e_t = 1'b0;
                           g_t = 1'b1;
                           l_t = 1'b0;
                         end
                        else 
                         begin
                           e_t = 1'b0;
                           g_t = 1'b0;
                           l_t = 1'b1;
                         end
                        end
                       
                       `MULT_INC:             //CMD = 1001 : INC both by 1 and multiply
                        begin
                        res_t = ( (opa_t + 1) * (opb_t + 1) );  //res_t size yet to be done
                        //res_t = MUL_RES;
                        end
                        //res_t = MUL_RES;
                        
                       
                       `MULT_SHIFT:             //CMD = 1010 : Left shift A by 1 and multiply with B            
                        begin
                        res_t = ( (opa_t << 1) * opb_t);    //res_t size yet to be done
                        //res_t = MUL_RES;
                        //res_t = MUL_RES;
                        end
                        
                       `SIGNED_ADD_CIN:
                        begin
                        res_t[Width-1:0] = $signed(opa_t) + $signed(opb_t);//opa_t + opb_t;
//                        res_t = $signed(opa_t) + $signed(opb_t);
                        oflow_t = ( ($signed(opa_t) > 0  && $signed(opb_t) > 0  && $signed(res_t[Width-1:0]) < 0) ||
                                    ($signed(opa_t) < 0  && $signed(opb_t) < 0  && $signed(res_t[Width-1:0]) > 0));
                        l_t = ($signed(opa_t) < $signed(opb_t));
                        e_t = ($signed(opa_t) == $signed(opb_t));
                        g_t = ($signed(opa_t) > $signed(opb_t));
                        end
                        
                       `SIGNED_SUB_CIN:
                        begin
                        res_t[Width-1:0] = $signed(opa_t) - $signed(opb_t);//opa_t - opb_t;
//                        res_t = $signed(opa_t) - $signed(opb_t);
                        oflow_t = ( ($signed(opa_t) >= 0  && $signed(opb_t) < 0  && $signed(res_t[Width-1:0]) < 0 ) || 
                                    ($signed(opa_t) < 0   && $signed(opb_t) >= 0   && $signed(res_t[Width-1:0]) >= 0));
                        l_t = ($signed(opa_t) < $signed(opb_t));
                        e_t = ($signed(opa_t) == $signed(opb_t));
                        g_t = ($signed(opa_t) > $signed(opb_t));
                        end
                        
                        default:    //For any other case send high impedence value
                        begin
                        err_t=1'b1;
                        end
                      
                      endcase 
                      
                end
                       
                
                2'b01:  //A
                begin
                    case(cmd_t)                   
                       `INC_A:            //CMD = 0100: INC_A
                        begin 
                        res_t = opa_t + 1;
                        cout_t = res_t[Width];
                        end
                         
                       `DEC_A:            //CMD = 0101: DEC_A
                        begin 
                        res_t = opa_t - 1;
                        cout_t = res_t[Width];
                        end
                        
                        default:    //For any other case send high impedence value
                        begin
                        err_t =1'b1;
                        end
                       endcase 
                end
                
                2'b10:  //B
                begin
                    case(cmd_t)
                       `INC_B:            //CMD = 0110: INC_B
                        begin 
                        res_t = opb_t+1;
                        cout_t = res_t[Width];
                        end
               
                       `DEC_B:            //CMD = 0111: DEC_B
                        begin 
                        res_t = opb_t-1;
                        cout_t = res_t[Width];
                        end
                        
                        default:    //For any other case send high impedence value
                        begin
                        err_t =1'b1;
                        end
                      endcase
               
                end
               
                default:    //For any other case send high impedence value
                begin
                res_t='b0;
                cout_t=1'b0;
                oflow_t=1'b0;
                g_t=1'b0;
                e_t=1'b0;
                l_t=1'b0;
                err_t=1'b1;
               end
              endcase
             end
             
/*-----------------------------------------------------------------------------------------------------------------------------------------*/
        
         else          //MODE signal is low, then this is a Logical Operation
         begin 
           
           case(inp_valid_t)
                2'b01:
                begin   
                    case(cmd_t) 
                        `NOT_A:res_t = {1'b0,~opa_t};             //CMD = 0110: NOT_A
                        
                        `SHR1_A:res_t = {1'b0,opa_t>>1};           //CMD = 1000: SHR1_A
                     
                        `SHL1_A:res_t = {1'b0,opa_t<<1};           //CMD = 1001: SHL1_A
                    
                        default:     //For any other case send high impedence value
                        begin
                        err_t=1'b1;
                        end
                      endcase 
                 end
                2'b10:
                begin
                    case(cmd_t)
                        `NOT_B:res_t = {1'b0,~opb_t};             //CMD = 0111: NOT_B
                        
                        `SHR1_B:res_t = {1'b0,opb_t>>1};           //CMD = 1010: SHR1_B
                     
                        `SHL1_B:res_t = {1'b0,opb_t<<1};           //CMD = 1011: SHL1_B
               
                        default:     //For any other case send high impedence value
                        begin
                        err_t=1'b1;
                        end
                      endcase 
                 end
                 
                2'b11:
                begin
                    case(cmd_t)     //CMD is the binary code value of the Logical Operation
                        `AND:res_t = {1'b0,opa_t&opb_t};        //CMD = 0000: AND
                    
                     
                        `NAND:res_t = {1'b0,~(opa_t&opb_t)};     //CMD = 0001: NAND
                     
                     
                        `OR:res_t = {1'b0,opa_t|opb_t};        //CMD = 0010: OR
                     
                     
                        `NOR:res_t = {1'b0,~(opa_t|opb_t)};     //CMD = 0011: NOR
                     
                     
                        `XOR:res_t = {1'b0,opa_t^opb_t};        //CMD = 0100: XOR
                     
                     
                        `XNOR:res_t = {1'b0,~(opa_t^opb_t)};     //CMD = 0101: XNOR
                     
                     
                        `ROL_A_B:                                  //CMD = 1100: ROL_A_B
                         begin 
                         shift_val = opb_t[shift_bits-1:0];
                         res_t = {1'b0 , opa_t << shift_val | opa_t >> ( (Width) - shift_val)}; 
                         err_t = (opb_t >= Width)? 1:0;
                         end
                     
                     
                        `ROR_A_B:                                //CMD = 1101: ROR_A_B 
                         begin 
                         shift_val = opb_t[shift_bits-1:0];
                         res_t = {1'b0 , opa_t >> shift_val | opa_t << ( (Width) - shift_val)}; 
                         err_t = (opb_t >= Width)? 1:0;
                         end
                     
                     
                        default:     //For any other case send high impedence value
                        begin
                        err_t=1'b1;
                        end
                      endcase 
                 end
                
                default:     //For any other case send high impedence value
                        begin
                        res_t='b0;
                        cout_t=1'b0;
                        oflow_t=1'b0;
                        g_t=1'b0;
                        e_t=1'b0;
                        l_t=1'b0;
                        err_t=1'b1;
                        end
               endcase       
                      
     end
    end
   end



always @(posedge CLK or posedge RST) begin
  if (RST) begin
    RES <= 0;
    COUT <= 0;
    OFLOW <= 0;
    G <= 0;
    E <= 0;
    L <= 0;
    ERR <= 0;
    MUL_RES <=0;
    end

   
 else if(cmd_t == `MULT_INC || cmd_t == `MULT_SHIFT)begin
  MUL_RES <= res_t;
  RES <= MUL_RES;
  COUT <= 0;
  OFLOW <= 0;
  G <= 0;
  E <= 0;
  L <= 0;
  end

 else begin
    RES <= res_t;
    COUT <= cout_t;
    OFLOW <= oflow_t;
    G <= g_t;
    E <= e_t;
    L <= l_t;
    ERR <= err_t;
  end
end   
endmodule
