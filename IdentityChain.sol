
pragma solidity >=0.4.22 ;
//pragma experimental ABIEncoderV2;

contract IdentityChain{

    address private owner;
    constructor() public {    owner = msg.sender;    }
    enum  aadhaar_passport_both{AADHAAR,AADHAAR_PASSPORT}
    enum  flag{GREEN,ORANGE,RED}

    struct aadhaar {
        uint64 aadhaar_number;
        string aadhaar_name;
        uint aadhaar_dob_year;
        string aadhaar_address;
        string aadhaar_sex;
    }

    struct passport{
        string passport_number;
        string passport_name;
        uint passport_dob_year;
        uint passport_expiry_year;
        string old_passport_number;
    }

    struct identity{
        uint64 aadhaar_number;
        aadhaar_passport_both status;
        aadhaar aadhaar_details;
        string passport_number;
        passport passport_details;
        flag criminal_records_flag;
    }
    struct log{
        string location;
        uint256 time;
        string reason;
    }
    struct search_record_struct{
        uint64 count;
        log[] logs;
    }
    mapping (uint64 => identity) private identity_mapped;
    mapping (uint64 => uint ) private aadhaar_exists;
    mapping (string => uint ) private passport_exists;
    mapping(string => uint64 ) private passport_to_aadhaar_mapping;
    mapping(uint64 => search_record_struct) private search_records_aadhaar;
    mapping (uint64 => uint ) private aadhaar_records_exists;

    string[] private passport_identity_data;
    uint64[] private aadhaar_identity_data;
    //-----------------------------------------------------Inserting Data into Blockchain-----------------------------------------------------------

     function add_aadhaar_details(
         uint64 aadhaar_number, string memory aadhaar_name, uint aadhaar_dob_year,
         string memory aadhaar_address, string memory  aadhaar_sex
         )   public only_owner check_aadhaar(aadhaar_number,true)
         returns (bool added_aadhaar){

             aadhaar_identity_data.push(aadhaar_number);
             aadhaar_exists[aadhaar_number]=1;
             identity_mapped[aadhaar_number].status = aadhaar_passport_both.AADHAAR;
             identity_mapped[aadhaar_number].aadhaar_number=aadhaar_number;
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_number = aadhaar_number;
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_name = aadhaar_name;
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_dob_year = aadhaar_dob_year;
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_address = aadhaar_address;
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_sex =  aadhaar_sex;
             identity_mapped[aadhaar_number].criminal_records_flag = flag.GREEN;

             return true;

     }
     //---------------------------------------------------------------------------------------------------------------------------------------------

    function add_passport_using_aadhaar(
        uint64 aadhaar_number,
         string memory passport_number,string  memory passport_name,
         uint passport_dob_year,  uint passport_expiry_year, string memory old_passport_number
        )   public only_owner check_aadhaar(aadhaar_number,false) check_passport(passport_number,true)
        returns (bool aaded_passport_using_aadhaar){


             identity_mapped[aadhaar_number].status = aadhaar_passport_both.AADHAAR_PASSPORT;

             passport_identity_data.push(passport_number);
             passport_exists[passport_number]=1;

             identity_mapped[aadhaar_number].passport_number = passport_number;
             identity_mapped[aadhaar_number].passport_details.passport_number = passport_number;
             identity_mapped[aadhaar_number].passport_details.passport_name = passport_name;
             identity_mapped[aadhaar_number].passport_details.passport_dob_year =passport_dob_year;
             identity_mapped[aadhaar_number].passport_details.passport_expiry_year = passport_expiry_year;
             identity_mapped[aadhaar_number].passport_details.old_passport_number = old_passport_number;
             passport_to_aadhaar_mapping[passport_number] = aadhaar_number;
             return true;

        }

     //---------------------------------------------------------------------------------------------------------------------------------------------

    function update_criminal_flag(uint64 aadhaar_number,string memory criminal_flag)
      public check_aadhaar(aadhaar_number,false) check_flag(aadhaar_number,criminal_flag)
      returns (bool flag_updated){
          if((identity_mapped[aadhaar_number].criminal_records_flag == flag.GREEN) && (compareStringsbyBytes(criminal_flag,"ORANGE"))){

            identity_mapped[aadhaar_number].criminal_records_flag =flag.ORANGE;
            return true;

        }else if((identity_mapped[aadhaar_number].criminal_records_flag == flag.GREEN) && (compareStringsbyBytes(criminal_flag,"RED"))){

            identity_mapped[aadhaar_number].criminal_records_flag =flag.RED;
            return true;

        }
        else if((identity_mapped[aadhaar_number].criminal_records_flag == flag.ORANGE) && (compareStringsbyBytes(criminal_flag,"RED"))){

            identity_mapped[aadhaar_number].criminal_records_flag =flag.RED;
            return true;

         }else{
             return false;
        }

    }
    function update_criminal_flag_using_passport(string memory passport_number,string memory criminal_flag)
      public check_passport(passport_number,false) check_flag_using_pass(passport_number,criminal_flag)
      returns (bool flag_updated){
          
        uint64 aadhaar_number = passport_to_aadhaar_mapping[passport_number];
        if((identity_mapped[aadhaar_number].criminal_records_flag == flag.GREEN) && (compareStringsbyBytes(criminal_flag,"ORANGE"))){

            identity_mapped[aadhaar_number].criminal_records_flag =flag.ORANGE;
            return true;

        }else if((identity_mapped[aadhaar_number].criminal_records_flag == flag.GREEN) && (compareStringsbyBytes(criminal_flag,"RED"))){

            identity_mapped[aadhaar_number].criminal_records_flag =flag.RED;
            return true;

        }
        else if((identity_mapped[aadhaar_number].criminal_records_flag == flag.ORANGE) && (compareStringsbyBytes(criminal_flag,"RED"))){

            identity_mapped[aadhaar_number].criminal_records_flag =flag.RED;
            return true;

         }else{
             return false;
        }

    }

     //--------------------------------------------------------------View Only methods---------------------------------------------------------------

    function view_aadhaar_passport_status(uint64 aadhaar_number) public view  returns (bool status_aadhar_only){
    if(identity_mapped[aadhaar_number].status == aadhaar_passport_both.AADHAAR){
        return true;
    }else{
        return false;
    }
    }

    function view_aadhaar_details(uint64 aadhaar_number)
    public view  check_aadhaar(aadhaar_number,false)
    returns( uint64 , string memory , uint , string memory , string memory  ){

            return (identity_mapped[aadhaar_number].aadhaar_number,
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_name,
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_dob_year,
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_address,
             identity_mapped[aadhaar_number].aadhaar_details.aadhaar_sex );
        }
    function view_passport_details(string memory passport_number)
    public view check_passport(passport_number,false)  
    returns(    string memory ,string  memory ,
         uint256 ,  uint256 , string memory  ){
        
        uint64 aadhaar_num = uint64(passport_to_aadhaar_mapping[passport_number]);
        
        return (identity_mapped[aadhaar_num].passport_number,
        identity_mapped[aadhaar_num].passport_details.passport_name,
        identity_mapped[aadhaar_num].passport_details.passport_dob_year,
        identity_mapped[aadhaar_num].passport_details.passport_expiry_year,
        identity_mapped[aadhaar_num].passport_details.old_passport_number);

    }

    function view_passport_using_aadhaar(uint64 aadhaar_num)
    public view check_aadhaar(aadhaar_num,false)  check_passport_present_status(aadhaar_num)
    returns(    string memory passport_number,string  memory passport_name,
         uint passport_dob_year,  uint passport_expiry_year, string memory old_passport_number ){
        return (identity_mapped[aadhaar_num].passport_number,
        identity_mapped[aadhaar_num].passport_details.passport_name,
        identity_mapped[aadhaar_num].passport_details.passport_dob_year,
        identity_mapped[aadhaar_num].passport_details.passport_expiry_year,
        identity_mapped[aadhaar_num].passport_details.old_passport_number);

    }

    function view_criminal_flag(bool is_aadhaar,uint64 aadhaar_number,string memory passport_number)
    public view check_aadhaar_passport_present_status( is_aadhaar, aadhaar_number, passport_number)
    returns (string memory criminal_flag_result){
       if(is_aadhaar){
           return flag_to_string(identity_mapped[aadhaar_number].criminal_records_flag);
       }
       else{
            aadhaar_number= uint64(passport_to_aadhaar_mapping[passport_number]);
            return flag_to_string(identity_mapped[aadhaar_number].criminal_records_flag);

       }
    }

    //-------------------------------------------------------LOG---------------------------------------------------------------
    function add_log_using_aadhaar(
        uint64 aadhaar_number, string memory location,string memory reason)
        public check_aadhaar(aadhaar_number,false)  returns(bool){

        if(aadhaar_records_exists[aadhaar_number]!=1){
            aadhaar_records_exists[aadhaar_number]=1;
            search_records_aadhaar[aadhaar_number].count = 1;
            search_records_aadhaar[aadhaar_number].logs.push(log(location,block.timestamp,reason));
        }else
        {
            search_records_aadhaar[aadhaar_number].count += 1;
            search_records_aadhaar[aadhaar_number].logs.push(log(location,block.timestamp,reason));
        }
        return true;
    }
    function view_log_using_aadhaar(uint64 aadhaar_number) public view
    check_aadhaar(aadhaar_number,false) check_log_present(aadhaar_number)
    returns(uint count,log[] memory log_array){

        return (search_records_aadhaar[aadhaar_number].count,search_records_aadhaar[aadhaar_number].logs);
    }

    function add_log_using_passport(
        string memory passport_number, string memory location,string memory reason)
        public check_passport(passport_number,false)  returns(bool){

        uint64 aadhaar_number = uint64(passport_to_aadhaar_mapping[passport_number]);
        if(aadhaar_exists[aadhaar_number]==1)
        {
            if(aadhaar_records_exists[aadhaar_number]!=1){
                aadhaar_records_exists[aadhaar_number]=1;
                search_records_aadhaar[aadhaar_number].count = 1;
                search_records_aadhaar[aadhaar_number].logs.push(log(location,block.timestamp,reason));
            }else
            {
                search_records_aadhaar[aadhaar_number].count += 1;
                search_records_aadhaar[aadhaar_number].logs.push(log(location,block.timestamp,reason));
            }
            return true;
        }else{
            revert("Error Aadhaar");
        }
    }
    function view_log_using_passport(string memory passport_number) public view
    check_passport(passport_number,false)  //check_log_present(aadhaar_number)
    returns(uint count,log[] memory log_array){
        uint64 aadhaar_number = uint64(passport_to_aadhaar_mapping[passport_number]);
        if(aadhaar_records_exists[aadhaar_number]==1)
        {
            return (search_records_aadhaar[aadhaar_number].count,search_records_aadhaar[aadhaar_number].logs);
        }else{
            revert("Passport Not linked to valid Aadhaar");
        }
    }

    //--------------------------------------------------------------Modifiers-----------------------------------------------------------------------
    modifier only_owner(){  require(owner==msg.sender,"Access denied!");    _;  }
    modifier check_aadhaar(uint64 aadhaar_number, bool b){
        if(b){
            require(aadhaar_exists[aadhaar_number] != 1,"Error Occurred : Aadhaar number already Exists");
        }else{
            require(aadhaar_exists[aadhaar_number] == 1,"Error Occurred : Aadhaar number does not Exists");
        }
        _;
    }
    modifier check_passport(string memory passport_number, bool b){
        if(b){
            require(passport_exists[passport_number] != 1,"Error Occurred : Passport number already Exists");
        }else{
            require(passport_exists[passport_number] == 1,"Error Occurred : Passport number does not Exists");
        }
        _;
    }
    modifier check_passport_present_status(uint64 aadhaar_number){
        require(identity_mapped[aadhaar_number].status == aadhaar_passport_both.AADHAAR_PASSPORT, "No Passport Data Found!");   _;
    }
    modifier check_aadhaar_passport_present_status(bool is_aadhaar,uint64 aadhaar_number,string memory passport_number){
        if(is_aadhaar){
            require(aadhaar_exists[aadhaar_number] == 1,"Invalid Aadhaar Number!");
        }else{
            require(passport_exists[passport_number] == 1,"Invalid Passport Number!");
        }
        _;

    }
    modifier check_flag(uint64 aadhaar_number,string memory criminal_flag){
        flag status_old = identity_mapped[aadhaar_number].criminal_records_flag;
        flag status_new = (compareStringsbyBytes(criminal_flag,"GREEN"))?flag.GREEN :
        (compareStringsbyBytes(criminal_flag,"ORANGE"))? flag.ORANGE :flag.RED;
         require(status_new >status_old,"Status cannot be changed back to lower level!");
        _;
    }
    modifier check_flag_using_pass(string memory passport_number,string memory criminal_flag){
        uint64 aadhaar_number = passport_to_aadhaar_mapping[passport_number];
        flag status_old = identity_mapped[aadhaar_number].criminal_records_flag;
        flag status_new = (compareStringsbyBytes(criminal_flag,"GREEN"))?flag.GREEN :
        (compareStringsbyBytes(criminal_flag,"ORANGE"))? flag.ORANGE :flag.RED;
         require(status_new >status_old,"Status cannot be changed back to lower level!");
        _;
    }
    modifier check_log_present(uint64 aadhaar_number){
        require(aadhaar_records_exists[aadhaar_number]==1,"No Serach record found!");_;
    }

    //------------------------------------------------------Pure functions-----------------------------------------------------------------------
    function flag_to_string(flag f) private pure  returns (string memory flag_in_string){

            if(f ==flag.GREEN){
                return "GREEN";
            }
            else if(f ==flag.ORANGE){
                return "ORANGE";
            }
            else{
                return "RED";
            }
    }
    function compareStringsbyBytes(string memory s1, string  memory s2) private pure returns(bool){
        return keccak256(bytes(s1)) == keccak256(bytes(s2));
    }
}


/*
COMMANDS------------------------------------------------------------------
compile
migrate
web3.eth.getAccounts().then(function(res) { accounts = res; } )
IdentityChain.deployed().then(function(res){ identity =res ; })
"111111111111","Name one","1990","Pune","MALE"
identity.add_aadhaar_details(1111,"aadhaar name",1990,"Pune","MALE");
identity.view_aadhaar_details(1111);
identity.update_criminal_flag(1111,"RED");
identity.view_criminal_flag(true,1111,"");
identity.update_criminal_flag(1111,"GREEN");      ----------- gives user defined errroooooorrrrrr

*/


