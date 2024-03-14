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
//output logic SCL, SDA
output logic SCL, //SDA
inout SDAin
    );
     logic SDA; //SDA for writing
     logic SDAR; //SDA for reading   
     logic SDAinOut=1'b0;
    assign SDAin  = !SDAinOut ? SDA : 1'bz;
    
    
    always @ (posedge clk)
    begin
       SDAR <= SDAin; 
    end   
    
    
    
logic [15:0] storeData;
logic sclClk = 1'b0;
logic slwClk = 1'b0;

//-----counter for 10kHz signals and offset for SDA/SCL transmit---------
//logic [3:0] counterSCL = 4'b0000; 
logic [8:0] counterSCL = 9'h000;
logic [8:0] counterSDA = 9'h000;
always_ff@(posedge clk)
begin
//offset for SDA and SCL clocks
if(counterSCL == 9'h1f4) 
    begin
    counterSCL <= 9'h000;
    sclClk <= ~sclClk;
    counterSDA <= 9'h000;
    //slwClk <= ~slwClk;
    end
else if(counterSDA == 9'h0fa) 
    begin
    counterSCL <= counterSCL + 1'b1;
    counterSDA <= counterSDA + 1'b1;
    //counterSDA <= 14'h0000;
    slwClk <= ~slwClk;
    end    
else
    begin 
    counterSCL <= counterSCL + 1'b1;
    counterSDA <= counterSDA + 1'b1;
    end
end 
//-----------------------------------------------------------------------
//--------------State declarations and register--------------------------
typedef enum {
//init/hold state for catchup on ACCELR
holdW,
//states to select and write to address on bus
startAddrSelW, 
addrWW6, addrWW5, addrWW4, addrWW3, addrWW2, addrWW1, addrWW0, addrWW,
ackAddrSelW1, ackAddrSelW2,
//states to select register to write to on module
regAddr7W, regAddr6W, regAddr5W, regAddr4W, regAddr3W, regAddr2W, regAddr1W, regAddr0W,
ackRegSelW1, ackRegSelW2,
//states to write data to reg
dataW7, dataW6, dataW5, dataW4, dataW3, dataW2, dataW1, dataW0,
ackW1, ackW2, stopW,
holdR1, holdR2,
//states to select and write to address on bus
startAddrSelR, 
addrRW6, addrRW5, addrRW4, addrRW3, addrRW2, addrRW1, addrRW0, addrRW,
ackAddrSelR1, ackAddrSelR2,
//states to select register to write to on module
regAddr7R, regAddr6R, regAddr5R, regAddr4R, regAddr3R, regAddr2R, regAddr1R, regAddr0R,
ackRegSelR1, ackRegSelR2, stopRegSelR, 
holdDataRead1, holdDataRead2,
//states to select device to read from on bus
startDataRead,
addrR6, addrR5, addrR4, addrR3, addrR2, addrR1, addrR0, addrR,
ackDataSendR1, ackDataSendR2,
//states to read MSB
dataRF, dataRE, dataRD, dataRC, dataRB, dataRA, dataR9, dataR8, 
ackDataReadR1, ackDataReadR2,
//states to read LSB
dataR7, dataR6, dataR5, dataR4, dataR3, dataR2, dataR1, dataR0,
nackR1, nackR2, stopR
} states;
//state register
states NS, PS;
logic [7:0] holdCount = 8'h00;
always_ff@(posedge slwClk) begin 

if(PS == holdW) 
begin
    if (holdCount == 8'h80)
    begin
    holdCount = 8'h00;
    PS<=NS;
    end
    else
    holdCount = holdCount + 1'b1;
    
end


//if(sclClk == 1'b1 && NS == startAddrSelW) PS<=NS;
//else if(sclClk == 1'b1 && NS == startAddrSelR) PS<=NS;
//else if (sclClk == 1'b1 && NS == startDataRead) PS<=NS;

//else if (sclClk == 1'b1 && NS == holdR1) PS<=NS;

//else if (sclClk == 1'b1 && NS == stopR) PS<=NS;


//else if (sclClk == 1'b0) PS<=NS;
else
PS<=NS;

end 
//-----------------------------------------------------------------------
//-----------------State Actions for I2C Bus-----------------------------
logic SCLSleep;
logic SCLWake;
assign SCL = (sclClk & SCLSleep) | SCLWake;
always_comb begin
SDAinOut = 1'b0;
//SDA = 1'bz;
SCLSleep = 1'b1;
SCLWake = 1'b0;
case (PS) //         storeData[]   SDA   I2CAddr[]  regAddr[]  
    //init/hold state for catchup on ACCELR, send data to output reg
    holdW:
        begin
        dataR = storeData;
        SCLWake = 1'b1;
        SDA = 1'b1;
        NS = startAddrSelW;
        end    
    //states to select and write to address on bus
    startAddrSelW:
        begin
        if (slwClk == 1'b1)SCLWake = 1'b1; 
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
        NS = ackAddrSelW1;
        end
    ackAddrSelW1:
        begin
        SDA = 1'b0; 
        NS = ackAddrSelW2;
        end    
    ackAddrSelW2:
        begin
        SDA = 1'b0;
        SCLSleep = 1'b0;
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
        NS = ackRegSelW1;
        end
    ackRegSelW1:
        begin
        SDA =  1'b0;
        NS = ackRegSelW2;
        end
    ackRegSelW2:
        begin
        SDA =  1'b0;
        SCLSleep = 1'b0;
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
        NS = ackW1;
        end
    ackW1:
        begin
        SDA = 1'b0;
        NS = ackW2;
        end
     ackW2:
        begin
        SDA = 1'b0;
        SCLSleep = 1'b0;
        NS = stopW;
        end    
    stopW:
        begin
        SDA = 1'b0;
        if (slwClk == 1'b0)SCLWake = 1'b1; 
        NS = holdR1;
        end  
    holdR1:
        begin
        SDA = 1'b1;
        SCLWake = 1'b1;
        NS = holdR2;
        end       
    holdR2:
        begin
        SDA = 1'b1;
        SCLWake = 1'b1;
        NS = startAddrSelR;
        end  
    //states to select and write to address on bus
    startAddrSelR:
        begin
        SDA = 1'b0;
        if (slwClk == 1'b1)SCLWake = 1'b1;
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
        NS = ackAddrSelR1;
        end
    ackAddrSelR1:
        begin
        SDA = 1'b0; 
        NS = ackAddrSelR2;
        end
    ackAddrSelR2:
        begin
        SDA = 1'b0; 
        SCLSleep = 1'b0;
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
        NS = ackRegSelR1;
        end
    ackRegSelR1:
        begin
        SDA =  1'b0;
        NS = ackRegSelR2;
        end
    ackRegSelR2:
        begin
        SDA =  1'b0;
        SCLSleep = 1'b0;
        NS = stopRegSelR;
        end
    //states to select device to read from on bus    
    stopRegSelR: 
        begin
        if (slwClk == 1'b0)SCLWake = 1'b1;
        SDA =  1'b0;
        NS = holdDataRead1;
        end
    holdDataRead1:
        begin
        SCLWake = 1'b1;
        SDA =  1'b1;
        NS = holdDataRead2;
        end
    holdDataRead2:
        begin
        SCLWake = 1'b1;
        SDA =  1'b1;
        NS = startDataRead;
        end
    startDataRead:
        begin
        if (slwClk == 1'b1)SCLWake = 1'b1;
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
        NS = ackDataSendR1;
        end
    ackDataSendR1:
        begin
        SDA = 1'b0;
        NS = ackDataSendR2;
        end
    ackDataSendR2:
        begin
        SDA = 1'b0;
        SCLSleep = 1'b0;
        NS = dataRF;
        end
    //states to read MSB   
    dataRF: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[15] = SDAR;
        NS = dataRE;
        end
    dataRE:
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[14] = SDAR;
        NS = dataRD;
        end 
    dataRD:
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[13] = SDAR;
        NS = dataRC;
        end  
    dataRC: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[12] = SDAR;
        NS = dataRB;
        end 
    dataRB: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[11] = SDAR;
        NS = dataRA;
        end 
    dataRA: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[10] = SDAR;
        NS = dataR9;
        end 
    dataR9: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[9] = SDAR;
        NS = dataR8;
        end 
    dataR8: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[8] = SDAR;
        NS = ackDataReadR1;
        end 
    ackDataReadR1:
        begin
        SDA = 1'b0;
        NS = ackDataReadR2;
        end
    ackDataReadR2:
        begin
        SDA = 1'b0;
        SCLSleep = 1'b0;
        NS = dataR7;
        end
    //states to read LSB
    dataR7: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[7] = SDAR;
        NS = dataR6;
        end 
    dataR6: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[6] = SDAR;
        NS = dataR5;
        end
    dataR5: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[5] = SDAR;
        NS = dataR4;
        end
    dataR4: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[4] = SDAR;
        NS = dataR3;
        end
    dataR3: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[3] = SDAR;
        NS = dataR2;
        end
    dataR2: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[2] = SDAR;
        NS = dataR1;
        end
    dataR1: 
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[1] = SDAR;
        NS = dataR0;
        end
    dataR0:
        begin
        //SDA = 1'b1;
        SDAinOut = 1'b1;
        storeData[0] = SDAR;
        NS = nackR1;
        end
    nackR1:
        begin
        SDA = 1'b0;
        NS = nackR2;
        end
    nackR2:
        begin
        SDA = 1'b0;
        SCLSleep = 1'b0;
        NS = stopR;
        end
    stopR:
        begin
        SDA = 1'b0;
        SCLWake = 1'b1;
        NS = holdW;
        end
    //default
    default:
        begin
        SDA = 1'b1;
        NS = holdW;
        end
endcase    
end    
endmodule
