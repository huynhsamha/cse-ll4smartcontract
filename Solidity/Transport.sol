pragma solidity ^0.4.18;

import './DateTime.sol';

contract Transport {
    
    DateTime private dt;
    
    address public addr_A;
    address public addr_B;
    
    uint8 public p_info; // product infomation: thông tin sản phẩm A cung cấp . 
    
    uint public m_A; // số  ether hiện tại của  A trong smart contract.
    uint public m_B; // số  ether hiện tại của  B trong smart contract.
    
    uint public t_B_nhan; // timestamp B received product to transfer
    uint public t_A_nhan; // timestamp A received product after B transfer
    uint32 public dt_B_tre_nhan; // delta time: độ trễ thời gian B đến nhận hàng 
    uint32 public dt_A_tre_gui;  // delta time: độ trễ thời gian A gửi hàng 
    uint32 public dt_B_tre_gui;  // delta time: độ trễ thời gian B gửi hàng 
    
    string public a_A_gui; // address A send product to B
    string public a_A_nhan; // address A receive product after B transfer
    
    uint32 public m_B_tre; // tiền bồi thường khi B đến trễ lúc nhận hàng 
    uint32 public m_B_huy; // tiền bồi thường khi B hủy đơn hàng.
    uint32 public m_B_tre_gui; // tiền bồi thường B giao trễ hàng 
    uint32 public m_B_khong_hang; // tiền bồi thường khi B không có hàng để giao 
    uint32 public m_B_hang_hong; // tiền bồi thường khi B làm hỏng số hàng 
    
    uint public m_A_tre_gui; // tiền bồi thường khi A gửi hàng trễ  => hủy hợp đồng 
    uint public m_A_khong_dung_hen; // tiền bồi thường khi A không đúng lịch hẹn 
    uint public m_A_khong_dung_hang; // tiền bồi thường khi A không cung cấp đúng hàng 
    
    // flags 
    bool private provided_info_A = false; // A đã cung cấp thông tin hàng 
    bool private provided_time_A = false; // A đã cung cấp thời gian giao nhận hàng 
    bool private provided_money_A = false; // A đã cung cấp thông tin tiền bồi thường  
    bool private provided_money_B = false; // B đã cung cấp thong tin tiền bồi thường 
    bool private sent_deposits_A = false; // A đã gửi đặt cọc 
    bool private sent_deposits_B = false; // B đã gửi đặt cọc 
    
    bool private passed_B_nhan_hang = false; // B đã nhận hàng 
    
    
    constructor(address address_A, address address_B, address addrDateTime) public {
        addr_A = address_A;
        addr_B = address_B;
        dt = DateTime(addrDateTime);
    }
    
    modifier onlyA() {
        require(msg.sender == addr_A);
        _;
    }
    
    modifier onlyB() {
        require(msg.sender == addr_B);
        _;
    }
    
    modifier only_A_or_B() {
        require(msg.sender == addr_A || msg.sender == addr_B);
        _;
    }
 
    modifier agreementCompleted() {
        require(provided_time_A && provided_info_A 
            && provided_money_A && provided_money_B
            && sent_deposits_A && sent_deposits_B);
        _;
    }
    
    modifier passed_B_nhanHang() {
        require(passed_B_nhan_hang);
        _;
    }
    
    function provideTime_A(
        uint32 _dt_A_tre_gui,
        uint32 _dt_B_tre_nhan,
        uint32 _dt_B_tre_gui,
        uint16 year_B, uint8 month_B, uint8 day_B, uint8 hour_B, uint8 minute_B,
        uint16 year_A, uint8 month_A, uint8 day_A, uint8 hour_A, uint8 minute_A
    )
    onlyA public {
        if (!provided_time_A) {
            dt_A_tre_gui = _dt_A_tre_gui;
            dt_B_tre_nhan = _dt_B_tre_nhan;
            dt_B_tre_gui = _dt_B_tre_gui;
            t_B_nhan = dt.toTimestamp(year_B, month_B, day_B, hour_B, minute_B);
            t_A_nhan = dt.toTimestamp(year_A, month_A, day_A, hour_A, minute_A);
        }
        provided_time_A = true;
    }
    
    function provideInfo_A(
        uint8 _p_info,
        string _a_A_gui,
        string _a_A_nhan
    )
    onlyA public {
        if (!provided_info_A) {
            p_info = _p_info;
            a_A_gui = _a_A_gui;
            a_A_nhan = _a_A_nhan;
        }
        provided_info_A = true;
    }
    
    function provideMoney_A(
        uint32 _m_B_tre,
        uint32 _m_B_tre_gui,
        uint32 _m_B_khong_hang,
        uint32 _m_B_hang_hong
    )
    onlyA public {
        if (!provided_money_A) {
            m_B_tre = _m_B_tre;
            m_B_tre_gui = _m_B_tre_gui;
            m_B_khong_hang = _m_B_khong_hang;
            m_B_hang_hong = _m_B_hang_hong;
        }
        provided_money_A = true;
    }
    
    function sendDeposits_A() onlyA payable public {
        if (!sent_deposits_A) {
            m_A = msg.value;
        }
        sent_deposits_A = true;
    }

    function provideMoney_B(
        uint32 _m_A_tre_gui,
        uint32 _m_A_khong_dung_hen,
        uint32 _m_A_khong_dung_hang
    )
    onlyB public {
        if (!provided_money_B) {
            m_A_tre_gui = _m_A_tre_gui;
            m_A_khong_dung_hang = _m_A_khong_dung_hang;
            m_A_khong_dung_hen = _m_A_khong_dung_hen;
        }
        provided_money_B = true;
    }
    
    function sendDeposits_B() onlyB payable public {
        if (!sent_deposits_B) {
            m_B = msg.value;
        }
        sent_deposits_B = true;
    }
    
    function checkCurrentBalance() only_A_or_B public view returns (uint) {
        return address(this).balance;
    }
    
    function trigger_B_nhan_hang_de_gui(
        uint16 year_B, uint8 month_B, uint8 day_B, uint8 hour_B, uint8 minute_B,
        uint16 year_A, uint8 month_A, uint8 day_A, uint8 hour_A, uint8 minute_A,  
        uint8 p_nhan
    )
    only_A_or_B agreementCompleted public {
        uint t_B_den_nhan = dt.toTimestamp(year_B, month_B, day_B, hour_B, minute_B);
        uint t_A_gui_hang = dt.toTimestamp(year_A, month_A, day_A, hour_A, minute_A);
        
        if (t_B_den_nhan > t_B_nhan) {
            // B den nhan hang tre 
            if (t_B_den_nhan - t_B_nhan <= dt_B_tre_nhan) {
                // chua qua thoi han, chi can boi thuong
                addr_A.transfer(m_B_tre);
                m_B -= m_B_tre;
            } else {
                // qua han, huy hop dong
                addr_A.transfer(m_A + m_B_huy);
                selfdestruct(addr_B);
            }
        } 
        
        if (t_A_gui_hang > t_B_nhan) {
            // A gui hang tre
            if (t_A_gui_hang - t_B_nhan <= dt_A_tre_gui) {
                // chua qua thoi han, chi can boi thuong
                addr_B.transfer(m_A_tre_gui);
                m_A -= m_A_tre_gui;
            } else {
                // qua han, huy hop dong
                addr_A.transfer(m_A - m_A_khong_dung_hen);
                selfdestruct(addr_B);
            }
        }
        
        if (p_nhan != p_info) {
            // A gui khong dung hang, huy hop dong
            addr_A.transfer(m_A - m_A_khong_dung_hang);
            selfdestruct(addr_B);
        }
        
        passed_B_nhan_hang = true;
    }
    
    function trigger_A_nhan_hang_B_giao(
        uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute,
        bool hang_on
    )
    only_A_or_B passed_B_nhanHang public {
        uint t_B_gui_den = dt.toTimestamp(year, month, day, hour, minute);
        
        if (t_B_gui_den > t_A_nhan) {
            // B gui hang den tre 
            if (t_B_gui_den - t_A_nhan <= dt_B_tre_gui) {
                // chua qua thoi han, chi can boi thuong
                addr_A.transfer(m_B_tre_gui);
                m_B -= m_B_tre;
            } else {
                // qua han, khong co hang, huy hop dong
                addr_A.transfer(m_A + m_B_khong_hang);
                selfdestruct(addr_B);
            }
        } 
        
        if (!hang_on) {
            // B gui hang khong on, boi thuong
            addr_A.transfer(m_B_hang_hong);
            m_B -= m_B_hang_hong;
        }
        
        // complete
        selfdestruct(addr_B);
    }
}
