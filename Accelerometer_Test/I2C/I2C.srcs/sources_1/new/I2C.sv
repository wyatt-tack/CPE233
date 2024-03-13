`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Wyatt Tack
// 
// Create Date: 03/12/2024 03:28:59 PM
// Design Name: I2C Reading Module
// Module Name: I2C
// Project Name: OTTER_MCU_GYRO
// Target Devices: Basys 3 Board, Developed for MPU6050 accelerometer
// Tool Versions: 1.0 Test
// Description: Uses state machine to continoutsly read 2 bytes from I2C module at
//              regAddrR and regAddrR+1, and write 1 byte to regAddrW
//              can be manipultated for other I2C commands later
// 
//////////////////////////////////////////////////////////////////////////////////


module I2C(
input clk,
input [7:0] I2CAddr, regAddrR, regAddrW,
output logic [15:0] dataR, 
input [7:0] dataW,
output logic SDA, SCL
    );
logic [15:0] storeData;
logic sclClk = 1'b0;
logic slwClk = 1'b0;

//-----counter for 10kHz signals and offset for SDA/SCL transmit---------
logic [16:0] counter = 17'h00000;
always_ff@(posedge clk)
begin
//offset for SDA and SCL clocks
if(counter == 17'h186a0) 
    begin
    counter <= 17'h00000;
    sclClk <= ~sclClk;
    end
else if(counter == 17'h0c350) 
    begin
    counter <= counter + 1'b1;
    slwClk <= ~slwClk;
    end    
else counter <= counter + 1'b1;
end 
//-----------------------------------------------------------------------
//--------------State declarations and register--------------------------
typedef enum {
//init/hold state for catchup on ACCELR
hold, 

//states to select and write to address on bus
startAddrSelW, 
addrWW6, addrWW5, addrWW4, addrWW3, addrWW2, addrWW1, addrWW0,
addrWW,
ackAddrSelW,
//states to select register to write to on module
regAddr7W, regAddr6W, regAddr5W, regAddr4W, regAddr3W, regAddr2W, regAddr1W, regAddr0W,
ackRegSelW,
//states to write data to reg
dataW7, dataW6, dataW5, dataW4, dataW3, dataW2, dataW1, dataW0,
ackW, stopW,

//states to select and write to address on bus
startAddrSelR, 
addrRW6, addrRW5, addrRW4, addrRW3, addrRW2, addrRW1, addrRW0,
addrRW,
ackAddrSelR,
//states to select register to write to on module
regAddr7R, regAddr6R, regAddr5R, regAddr4R, regAddr3R, regAddr2R, regAddr1R, regAddr0R,
ackRegSelR,
//states to select device to read from on bus
startDataRead,
addrR6, addrR5, addrR4, addrR3, addrR2, addrR1, addrR0,
addrR,
ackDataSendR,
//states to read MSB
dataRF, dataRE, dataRD, dataRC, dataRB, dataRA, dataR9, dataR8, 
ackDataReadR,
//states to read LSB
dataR7, dataR6, dataR5, dataR4, dataR3, dataR2, dataR1, dataR0,
nackR, stopR
} states;
//state register
states NS, PS;
always_ff@(posedge slwClk) begin 
PS<=NS;
end 
//-----------------------------------------------------------------------
//-----------------State Actions for I2C Bus-----------------------------
assign SCL = sclClk;
always_comb begin
SDA = 1'bz;
case (PS) //         storeData[]   SDA   I2CAddr[]  regAddr[]  
    //init/hold state for catchup on ACCELR, send data to output reg
    hold:
        begin
        dataR = storeData;
        SDA = 1'b1;
        NS = startAddrSelR;
        end
          
    //states to select and write to address on bus
    startAddrSelW:
        begin
        SDA = 1'b0;
        NS = addrWW6;
        end
    addrWW6:
        begin
        SDA = I2CAddr[6]; 
        NS = addrWW5;
        end 
    addrWW5:
        begin
        SDA = I2CAddr[5]; 
        NS = addrWW4;
        end 
    addrWW4: 
        begin
        SDA = I2CAddr[4]; 
        NS = addrWW3;
        end
    addrWW3:
        begin
        SDA = I2CAddr[3]; 
        NS = addrWW2;
        end 
    addrWW2:
        begin
        SDA = I2CAddr[2]; 
        NS = addrWW1;
        end 
    addrWW1: 
        begin
        SDA = I2CAddr[1]; 
        NS = addrWW0;
        end
    addrWW0:
        begin
        SDA = I2CAddr[0]; 
        NS = addrWW;
        end
    addrWW:
        begin
        SDA = 1'b0; 
        NS = ackAddrSelW;
        end
    ackAddrSelW:
        begin
        SDA = 1'bz; 
        NS = regAddr7W;
        end    
        
     //states to select register to write to on module
    regAddr7W: 
        begin
        SDA =  regAddrW[7];
        NS = regAddr6W;
        end
    regAddr6W: 
        begin
        SDA =  regAddrW[6];
        NS = regAddr5W;
        end
    regAddr5W: 
        begin
        SDA =  regAddrW[5];
        NS = regAddr4W;
        end
    regAddr4W: 
        begin
        SDA =  regAddrW[4];
        NS = regAddr3W;
        end
    regAddr3W: 
        begin
        SDA =  regAddrW[3];
        NS = regAddr2W;
        end
    regAddr2W: 
        begin
        SDA =  regAddrW[2];
        NS = regAddr1W;
        end
    regAddr1W: 
        begin
        SDA =  regAddrW[1];
        NS = regAddr0W;
        end
    regAddr0W:
        begin
        SDA =  regAddrW[0];
        NS = ackRegSelW;
        end
    ackRegSelW:
        begin
        SDA =  1'bz;
        NS = dataW7;
        end    
    //states to write to reg
    dataW7: 
        begin
        SDA = dataW[7];
        NS = dataW6;
        end 
    dataW6: 
        begin
        SDA = dataW[6];
        NS = dataW5;
        end
    dataW5: 
        begin
        SDA = dataW[5];
        NS = dataW4;
        end
    dataW4: 
        begin
        SDA = dataW[4];
        NS = dataW3;
        end
    dataW3: 
        begin
        SDA = dataW[3];
        NS = dataW2;
        end
    dataW2: 
        begin
        SDA = dataW[2];
        NS = dataW1;
        end
    dataW1: 
        begin
        SDA = dataW[1];
        NS = dataW0;
        end
    dataW0:
        begin
        SDA = dataW[0];
        NS = ackW;
        end
    ackW:
        begin
        SDA = 1'bz;
        NS = stopW;
        end
    stopW:
        begin
        SDA = 1'b1;
        NS = startAddrSelR;
        end  
           
    //states to select and write to address on bus
    startAddrSelR:
        begin
        SDA = 1'b0;
        NS = addrRW6;
        end
    addrRW6:
        begin
        SDA = I2CAddr[6]; 
        NS = addrRW5;
        end 
    addrRW5:
        begin
        SDA = I2CAddr[5]; 
        NS = addrRW4;
        end 
    addrRW4: 
        begin
        SDA = I2CAddr[4]; 
        NS = addrRW3;
        end
    addrRW3:
        begin
        SDA = I2CAddr[3]; 
        NS = addrRW2;
        end 
    addrRW2:
        begin
        SDA = I2CAddr[2]; 
        NS = addrRW1;
        end 
    addrRW1: 
        begin
        SDA = I2CAddr[1]; 
        NS = addrRW0;
        end
    addrRW0:
        begin
        SDA = I2CAddr[0]; 
        NS = addrRW;
        end
    addrRW:
        begin
        SDA = 1'b0; 
        NS = ackAddrSelR;
        end
    ackAddrSelR:
        begin
        SDA = 1'bz; 
        NS = regAddr7R;
        end
    //states to select register to write to on module
    regAddr7R: 
        begin
        SDA =  regAddrR[7];
        NS = regAddr6R;
        end
    regAddr6R: 
        begin
        SDA =  regAddrR[6];
        NS = regAddr5R;
        end
    regAddr5R: 
        begin
        SDA =  regAddrR[5];
        NS = regAddr4R;
        end
    regAddr4R: 
        begin
        SDA =  regAddrR[4];
        NS = regAddr3R;
        end
    regAddr3R: 
        begin
        SDA =  regAddrR[3];
        NS = regAddr2R;
        end
    regAddr2R: 
        begin
        SDA =  regAddrR[2];
        NS = regAddr1R;
        end
    regAddr1R: 
        begin
        SDA =  regAddrR[1];
        NS = regAddr0R;
        end
    regAddr0R:
        begin
        SDA =  regAddrR[0];
        NS = ackRegSelR;
        end
    ackRegSelR:
        begin
        SDA =  1'bz;
        NS = startDataRead;
        end
    //states to select device to read from on bus    
    startDataRead:
        begin
        SDA =  1'b0;
        NS = addrR6;
        end
    addrR6: 
        begin
        SDA = I2CAddr[6];
        NS = addrR5;
        end
    addrR5:
        begin
        SDA = I2CAddr[5];
        NS = addrR4;
        end 
    addrR4:
        begin
        SDA = I2CAddr[4];
        NS = addrR3;
        end 
    addrR3: 
        begin
        SDA = I2CAddr[3];
        NS = addrR2;
        end
    addrR2: 
        begin
        SDA = I2CAddr[2];
        NS = addrR1;
        end
    addrR1:
        begin
        SDA = I2CAddr[1];
        NS = addrR0;
        end 
    addrR0:
        begin
        SDA = I2CAddr[0];
        NS = addrR;
        end
    addrR:
        begin
        SDA = 1'b1;
        NS = ackDataSendR;
        end
    ackDataSendR:
        begin
        SDA = 1'bz;
        NS = dataRF;
        end
    //states to read MSB   
    dataRF: 
        begin
        SDA = 1'bz;
        storeData[15] = SDA;
        NS = dataRE;
        end
    dataRE:
        begin
        SDA = 1'bz;
        storeData[14] = SDA;
        NS = dataRD;
        end 
    dataRD:
        begin
        SDA = 1'bz;
        storeData[13] = SDA;
        NS = dataRC;
        end  
    dataRC: 
        begin
        SDA = 1'bz;
        storeData[12] = SDA;
        NS = dataRB;
        end 
    dataRB: 
        begin
        SDA = 1'bz;
        storeData[11] = SDA;
        NS = dataRA;
        end 
    dataRA: 
        begin
        SDA = 1'bz;
        storeData[10] = SDA;
        NS = dataR9;
        end 
    dataR9: 
        begin
        SDA = 1'bz;
        storeData[9] = SDA;
        NS = dataR8;
        end 
    dataR8: 
        begin
        SDA = 1'bz;
        storeData[8] = SDA;
        NS = ackDataReadR;
        end 
    ackDataReadR:
        begin
        SDA = 1'b0;
        NS = dataR7;
        end
    //states to read LSB
    dataR7: 
        begin
        SDA = 1'bz;
        storeData[7] = SDA;
        NS = dataR6;
        end 
    dataR6: 
        begin
        SDA = 1'bz;
        storeData[6] = SDA;
        NS = dataR5;
        end
    dataR5: 
        begin
        SDA = 1'bz;
        storeData[5] = SDA;
        NS = dataR4;
        end
    dataR4: 
        begin
        SDA = 1'bz;
        storeData[4] = SDA;
        NS = dataR3;
        end
    dataR3: 
        begin
        SDA = 1'bz;
        storeData[3] = SDA;
        NS = dataR2;
        end
    dataR2: 
        begin
        SDA = 1'bz;
        storeData[2] = SDA;
        NS = dataR1;
        end
    dataR1: 
        begin
        SDA = 1'bz;
        storeData[1] = SDA;
        NS = dataR0;
        end
    dataR0:
        begin
        SDA = 1'bz;
        storeData[0] = SDA;
        NS = nackR;
        end
    nackR:
        begin
        SDA = 1'b1;
        NS = stopR;
        end
    stopR:
        begin
        SDA = 1'b0;
        NS = hold;
        end
    //default
    default:
        begin
        SDA = 1'b1;
        NS = hold;
        end
endcase    
end    
endmodule
