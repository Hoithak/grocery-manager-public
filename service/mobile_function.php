<?php
    
    // UUID generator
    function gen_uuid() {
        return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        // 32 bits for "time_low"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),

        // 16 bits for "time_mid"
        mt_rand( 0, 0xffff ),

        // 16 bits for "time_hi_and_version",
        // four most significant bits holds version number 4
        mt_rand( 0, 0x0fff ) | 0x4000,

        // 16 bits, 8 bits for "clk_seq_hi_res",
        // 8 bits for "clk_seq_low",
        // two most significant bits holds zero and one for variant DCE1.1
        mt_rand( 0, 0x3fff ) | 0x8000,

        // 48 bits for "node"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff )
        );
    }

    // Expiration check
    function exp_check($expiration, $stock) {

        if ($expiration == "0000-00-00" || $expiration == "" || $expiration == NULL) {
            return $stock;
        }

        $date_now = date("m/d/Y");
        $three_month = date('m/d/Y', strtotime("+3 months", strtotime($date_now)));
        $date_exp = date('m/d/Y', strtotime($expiration));

        if (strtotime($date_exp) <= strtotime($three_month)) {
            $stock = 0;
        }

        return $stock;
    }


    // Round price to 5 or 9
    function roundPrice(float $price) {
        $price = sprintf("%.2f", $price);
        $res = explode(".", $price);
        $number = $res[0];
        $point = $res[1];
        $firstDigit = $point[0];
        $secondDigit = $point[1];
        if ($secondDigit < 6) {
            $secondDigit = '5';
        }
        else {
            $secondDigit = '9';
        }
        return floatval($number .'.'. $firstDigit.$secondDigit);
    }

    // Get Adjust Price Function
    function getAdjustPrice(array $adjusts, float $weight) {
        $adj_price = 0.00;
        foreach ($adjusts as $adjust) {
            if($weight < floatval($adjust->weight)){
                $adj_price = $adjust->adjust;
                break;
            }
        }
        return $adj_price;
    }
    
?>
