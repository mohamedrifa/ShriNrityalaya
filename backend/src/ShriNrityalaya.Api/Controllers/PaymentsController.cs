using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly IRepository<Payment> _repository;

    public PaymentsController(IRepository<Payment> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> GetAll()
    {
        var payments = await _repository.GetAllAsync();
        return Ok(new { success = true, data = payments });
    }

    [HttpGet("obligation/{obligationId}")]
    [Authorize(Roles = "Parent,Student,Teacher,SystemAdmin")]
    public async Task<IActionResult> GetByObligation(Guid obligationId)
    {
        var payments = await _repository.GetAllAsync();
        var payment = payments.OrderByDescending(p => p.CreatedAt)
                              .FirstOrDefault(p => p.MonthlyFeeObligationId == obligationId);
        
        if (payment == null) return NotFound(new { success = false, message = "Payment not found." });

        return Ok(new { success = true, data = payment });
    }

    [HttpPost("submit-proof")]
    [Authorize(Roles = "Parent,Student,Teacher,SystemAdmin")]
    public async Task<IActionResult> SubmitProof(
        [FromForm] Guid studentId,
        [FromForm] Guid monthlyFeeObligationId,
        [FromForm] decimal amount,
        [FromForm] string paymentMethod,
        [FromForm] string transactionReference,
        IFormFile proofImage)
    {
        var payment = new Payment
        {
            StudentId = studentId,
            MonthlyFeeObligationId = monthlyFeeObligationId,
            Amount = amount,
            PaymentMethod = paymentMethod,
            TransactionReference = transactionReference,
            PaymentDate = DateTime.UtcNow,
            Status = "PendingReview",
            CreatedAt = DateTimeOffset.UtcNow
        };

        if (proofImage != null && proofImage.Length > 0)
        {
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(proofImage.FileName);
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await proofImage.CopyToAsync(stream);
            }

            payment.ProofImageUrl = "/uploads/" + fileName;
        }

        var created = await _repository.AddAsync(payment);

        // Also update obligation status to Under Review
        var obligationRepo = HttpContext.RequestServices.GetRequiredService<IRepository<MonthlyFeeObligation>>();
        var obligation = await obligationRepo.GetByIdAsync(monthlyFeeObligationId);
        if (obligation != null)
        {
            obligation.Status = "Under Review";
            await obligationRepo.UpdateAsync(obligation);
        }

        return Ok(new { success = true, message = "Payment submitted for review.", data = created });
    }

    [HttpPost("manual-cash")]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> RecordManualCashPayment([FromBody] ManualCashRequest request)
    {
        var obligationRepo = HttpContext.RequestServices.GetRequiredService<IRepository<MonthlyFeeObligation>>();
        var obligation = await obligationRepo.GetByIdAsync(request.MonthlyFeeObligationId);
        
        if (obligation == null) return NotFound("Obligation not found");

        var payment = new Payment
        {
            StudentId = obligation.StudentId,
            MonthlyFeeObligationId = obligation.Id,
            Amount = obligation.AmountDue,
            PaymentMethod = "Cash",
            TransactionReference = "MANUAL_CASH_" + DateTime.UtcNow.Ticks,
            PaymentDate = DateTime.UtcNow,
            Status = "Approved",
            CreatedAt = DateTimeOffset.UtcNow,
            ReviewRemarks = "Received manually by Teacher"
        };

        var created = await _repository.AddAsync(payment);

        obligation.Status = "Paid";
        obligation.AmountPaid = payment.Amount;
        await obligationRepo.UpdateAsync(obligation);

        return Ok(new { success = true, message = "Cash payment recorded successfully.", data = created });
    }

    [HttpPut("{id}/review")]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> ReviewPayment(Guid id, [FromBody] ReviewPaymentRequest request)
    {
        var payment = await _repository.GetByIdAsync(id);
        if (payment == null) return NotFound();

        payment.Status = request.Status; // "Approved" or "Rejected"
        payment.ReviewRemarks = request.Remarks;
        payment.UpdatedAt = DateTimeOffset.UtcNow;

        await _repository.UpdateAsync(payment);

        // Update corresponding Obligation
        if (payment.MonthlyFeeObligationId.HasValue)
        {
            var obligationRepo = HttpContext.RequestServices.GetRequiredService<IRepository<MonthlyFeeObligation>>();
            var obligation = await obligationRepo.GetByIdAsync(payment.MonthlyFeeObligationId.Value);
            if (obligation != null)
            {
                if (request.Status == "Approved")
                {
                    obligation.Status = "Paid";
                    obligation.AmountPaid = payment.Amount;
                }
                else if (request.Status == "Rejected")
                {
                    obligation.Status = "Unpaid";
                }
                await obligationRepo.UpdateAsync(obligation);
            }
        }

        return Ok(new { success = true, message = $"Payment {request.Status} successfully." });
    }
}

public class ReviewPaymentRequest
{
    public string Status { get; set; } = string.Empty;
    public string? Remarks { get; set; }
}

public class ManualCashRequest
{
    public Guid MonthlyFeeObligationId { get; set; }
}
