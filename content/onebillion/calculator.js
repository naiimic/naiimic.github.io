function calculateBillionSeconds() {
    const birthdate = document.getElementById('birthdate').value;
    if (!birthdate) {
        document.getElementById('result').innerHTML = "Please enter your birthdate!";
        return;
    }
    
    let birthDateTime = birthdate;
    const birthtime = document.getElementById('birthtime').value;
    if (birthtime) {
        birthDateTime += 'T' + birthtime;
    } else {
        birthDateTime += 'T00:00:00';
    }
    
    const birthTimestamp = new Date(birthDateTime).getTime();
    const billionSecondsTimestamp = birthTimestamp + (1000000000 * 1000);
    const billionSecondsDate = new Date(billionSecondsTimestamp);
    
    const options = { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric',
        hour: 'numeric',
        minute: 'numeric'
    };
    
    document.getElementById('result').innerHTML = 
        "<div>You will be 1 billion seconds old on:</div>" + 
        "<div class='billion-result'>" + billionSecondsDate.toLocaleDateString(undefined, options) + "</div>";
}

function resetForm() {
    document.getElementById('birthdate').value = '';
    document.getElementById('birthtime').value = '';
    document.getElementById('result').innerHTML = '';
    validateForm();
}

function validateForm() {
    const birthdate = document.getElementById('birthdate').value;
    const calculateBtn = document.getElementById('calculateBtn');
    
    if (birthdate) {
        calculateBtn.disabled = false;
        calculateBtn.classList.remove('btn-disabled');
    } else {
        calculateBtn.disabled = true;
        calculateBtn.classList.add('btn-disabled');
    }
}

// Initialize the form when the page loads
document.addEventListener('DOMContentLoaded', function() {
    const birthdateInput = document.getElementById('birthdate');
    const resetBtn = document.getElementById('resetBtn');
    
    if (birthdateInput) {
        birthdateInput.addEventListener('change', validateForm);
        validateForm(); // Initialize button state
    }
    
    if (resetBtn) {
        resetBtn.addEventListener('click', resetForm);
    }
}); 